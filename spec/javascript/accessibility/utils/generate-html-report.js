const fs = require("fs");
const path = require("path");

const inputPath = "./axe-reports/report-latest.json";
const outputPath = "./public/accessibility-report.html";

const severityColors = {
  critical: "#f44336", // red
  serious: "#ff9800", // orange
  moderate: "#ffeb3b", // yellow
  minor: "#8bc34a", // green
};

function generateHTML(results) {
  const violations = results.violations || [];
  const byImpact = {};

  for (const violation of violations) {
    const impact = violation.impact || "minor";
    if (!byImpact[impact]) byImpact[impact] = [];
    byImpact[impact].push(violation);
  }

  const content = Object.entries(byImpact)
    .map(([impact, items]) => {
      const color = severityColors[impact] || "#ccc";
      return `
      <section style="border-left: 8px solid ${color}; padding: 1em; margin-bottom: 1em; background: #fff;">
        <h2 style="color:${color}">${impact.toUpperCase()} Issues (${
        items.length
      })</h2>
        ${items
          .map(
            (item) => `
            <div style="padding:1em; margin: 1em 0; border: 1px solid #ddd; border-left: 4px solid ${color}; background: #f9f9f9;">
              <h3 style="margin: 0 0 0.5em 0;">❌ ${item.help}</h3>
              <p><strong>Description:</strong> ${item.description}</p>
              <p><strong>More info:</strong> <a href="${
                item.helpUrl
              }" target="_blank">${item.helpUrl}</a></p>
              <p><strong>Instances:</strong></p>
              <ul>
                ${item.nodes
                  .map(
                    (node) => `
                      <li style="margin-bottom: 0.5em;">
                        <div><strong>Element HTML:</strong> <code>${escapeHTML(
                          node.html
                        )}</code></div>
                        <div><strong>Selector:</strong> <code>${node.target.join(
                          ", "
                        )}</code></div>
                      </li>
                    `
                  )
                  .join("")}
              </ul>
            </div>
          `
          )
          .join("")}
      </section>
      `;
    })
    .join("");

  return `<!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="utf-8" />
      <title>Accessibility Report</title>
      <style>
        body { font-family: Arial, sans-serif; padding: 2em; background: #eee; line-height: 1.6; }
        code { background: #eee; padding: 0.2em 0.4em; border-radius: 4px; font-size: 90%; }
        a { color: #0645ad; }
      </style>
    </head>
    <body>
      <h1>Accessibility Report</h1>
      <p><strong>Generated:</strong> ${new Date().toLocaleString()}</p>
      <p><strong>Total Violations:</strong> ${violations.length}</p>
      ${
        content ||
        "<p style='color:green; font-weight:bold;'>No violations found! 🎉</p>"
      }
    </body>
  </html>`;
}

function escapeHTML(str) {
  return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// Run generator
if (!fs.existsSync(inputPath)) {
  console.error(`❌ Input file not found: ${inputPath}`);
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(inputPath, "utf8"));
const html = generateHTML(data);

fs.mkdirSync(path.dirname(outputPath), { recursive: true });
fs.writeFileSync(outputPath, html);

console.log(`✅ Accessibility HTML report generated at: ${outputPath}`);
