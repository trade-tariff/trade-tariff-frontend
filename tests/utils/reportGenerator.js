// reportGenerator.js
const fs = require("fs");
const path = require("path");
const htmlPdf = require("html-pdf-node");
const base64Img = require("base64-img");

const generateSeverityColor = (impact) => {
  switch (impact) {
    case "critical":
      return "red";
    case "serious":
      return "orange";
    case "moderate":
      return "gold";
    case "minor":
      return "green";
    default:
      return "gray";
  }
};

async function generateAxeReport(
  results,
  reportName = "report",
  screenshotPath = null
) {
  const formattedResults = results.violations
    .map(
      (violation) => `
      <div style="border-left: 8px solid ${generateSeverityColor(
        violation.impact
      )}; padding: 12px; margin: 16px 0; background-color: #f9f9f9;">
        <h3 style="color: ${generateSeverityColor(
          violation.impact
        )};">${violation.impact.toUpperCase()} - ${violation.id}</h3>
        <p><strong>Description:</strong> ${violation.description}</p>
        <p><strong>Help:</strong> <a href="${
          violation.helpUrl
        }" target="_blank">${violation.help}</a></p>
        <ul>
          ${violation.nodes
            .map(
              (node) => `
              <li>
                <pre style="background:#eee; padding:8px;">${node.html
                  .replace(/</g, "&lt;")
                  .replace(/>/g, "&gt;")}</pre>
                <p>${node.failureSummary}</p>
              </li>
            `
            )
            .join("")}
        </ul>
      </div>
    `
    )
    .join("");

  let screenshotBase64 = null;
  if (screenshotPath) {
    screenshotBase64 = base64Img.base64Sync(screenshotPath);
  }

  const screenshotSection = screenshotBase64
    ? `<h3>Screenshot of the Issue:</h3><img src="${screenshotBase64}" alt="Accessibility Issue Screenshot" width="600" style="border: 1px solid #ccc; margin: 20px 0;">`
    : "";

  const htmlContent = `
    <html>
      <head>
        <title>Axe Accessibility Report</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 20px; }
          h1 { color: #2c3e50; }
          pre { overflow-x: auto; background:#f0f0f0; padding: 10px; border-radius: 5px;}
          a { color: #007acc; text-decoration: none; }
          a:hover { text-decoration: underline; }
          img { max-width: 100%; }
        </style>
      </head>
      <body>
        <h1>Axe Accessibility Report</h1>
        ${screenshotSection}
        ${formattedResults || "<p>No violations found!</p>"}
      </body>
    </html>
  `;

  const reportsDir = path.join(__dirname, "../reports");
  if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir);

  const htmlPath = path.join(reportsDir, `${reportName}.html`);
  const pdfPath = path.join(reportsDir, `${reportName}.pdf`);

  // Save the HTML report
  fs.writeFileSync(htmlPath, htmlContent, "utf8");

  // Generate and save the PDF report
  const file = { content: htmlContent };
  const pdfBuffer = await htmlPdf.generatePdf(file, { format: "A4" });
  fs.writeFileSync(pdfPath, pdfBuffer);

  console.log(`✅ Reports generated:\n- ${htmlPath}\n- ${pdfPath}`);
}

module.exports = { generateAxeReport };
