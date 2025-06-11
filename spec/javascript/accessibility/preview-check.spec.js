const { test, expect } = require("@playwright/test");

test.describe('Preview environment smoke test', () => {
  test.use({
    actionTimeout: 60000,
    navigationTimeout: 60000,
  });

  test('/find_commodity loads and returns expected results', async ({ page }) => {
    test.setTimeout(150000);

    try {
      console.log('Navigating to /find_commodity...');
      await page.goto('/find_commodity');

      const isAuthPage = await page.locator('h1:has-text("non-production Online Trade Tariff")').isVisible();
      console.log('Is authentication page:', isAuthPage);

      if (isAuthPage) {
        console.log('Handling authentication...');

        const passwordInput = page.locator('#basic-session-password-field');
        await expect(passwordInput).toBeVisible();

        const password = process.env.BASIC_PASSWORD;
        await passwordInput.fill(password);

        console.log('Clicking continue button...');
        const continueButton = page.locator('button.govuk-button:has-text("Continue")');
        await expect(continueButton).toBeVisible();

        await Promise.all([
          page.waitForURL(url => url.pathname === '/find_commodity'),
          continueButton.click()
        ]);

        console.log('Waiting for search page to load...');
        await page.waitForSelector('input[placeholder="Enter the name of the goods or commodity code"]', {
          timeout: 90000,
          state: 'visible'
        });

        // await page.screenshot({ path: 'after-auth-navigation.png' });
        console.log('Authentication successful');
      }

      console.log('Verifying page title...');
      await expect(
            page.getByRole('heading', { level: 1, name: /Look up commodity codes, import duties, taxes and controls/i })
            ).toBeVisible();

      // await page.screenshot({ path: 'before-search.png' });

      console.log('Performing search...');
      const searchInput = page.getByPlaceholder('Enter the name of the goods or commodity code');
      await searchInput.fill('0101210000');
      await page.getByRole('button', { name: /search/i }).click();

      console.log('Waiting for search results...');
      await expect(page.locator('text=0101210000').first()).toBeVisible({ timeout: 90000 });
      await page.screenshot({ path: 'after-search.png' });

      console.log('Test completed successfully');
    } catch (error) {
      console.error('Test failed:', error);
      await page.screenshot({ path: 'test-failure.png' });
      throw error;
    }
  });
});
