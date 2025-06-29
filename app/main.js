import express from "express";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 8080;
const serviceLabel = process.env.SERVICE_LABEL || "Coming Soon";
const egressTestUrl = process.env.EGRESS_TEST_URL;

// Express configuration
app.set("view engine", "hbs");
app.set("views", path.join(__dirname, "views"));
app.use(express.static(path.join(__dirname, "public")));
app.disable("x-powered-by");

// Ignore favicon.ico requests
app.get("/favicon.ico", (req, res) => {
  res.status(204).send();
});

// Test egress route
app.get("/test-egress", async (req, res) => {
  if (!egressTestUrl) {
    console.log(
      "EGRESS_TEST_URL is not set. Skipping and falling back to default route.  ",
    );
    console.log(
      `Request received at path "${req.path}" with query "${JSON.stringify(req.query)}"`,
    );
    res.render("index", {
      serviceLabel,
    });
    return;
  }

  try {
    console.log(`Testing egress using URL: ${egressTestUrl}`);
    const response = await fetch(egressTestUrl, { timeout: 10000 });
    // Get the response body as text
    const text = await response.text();
    console.log("Egress test response:", text);
    res.status(response.status).send();
  } catch (err) {
    console.error("Egress test failed:", err);
    res.status(500).send("");
  }
});

// TODO: Additional routes


// Fallback route
app.use((req, res) => {
  console.log(
    `Fallback route handling request at path "${req.path}" with query "${JSON.stringify(req.query)}"`,
  );
  res.render("index", {
    serviceLabel,
  });
});

// -------------------------------------

async function getIpAddress() {
  try {
    const ipUrl = "https://api.ipify.org?format=json";
    const response = await fetch(ipUrl, { timeout: 10000 });
    const data = await response.json();
    return data.ip;
  } catch (err) {
    console.error("Cannot retrieve IP from ipify.org:", err);
    return "UNKNOWN";
  }
}

async function main() {
  try {
    const ip = await getIpAddress();

    app.listen(PORT, () => {
      console.log(
        `Server listening on port ${PORT} using a source IP of ${ip} with SERVICE_LABEL: ${serviceLabel}`,
      );
    });
  } catch (err) {
    console.error("Failed to start server:", err);
    process.exit(1);
  }
}

main().catch((err) => {
  console.error("Unhandled error:", err);
  process.exit(1);
});
