import dotenv from "dotenv";
import { createApp } from "./app.js";

dotenv.config();

const port = Number(process.env.PORT || 4010);
const host = process.env.HOST || "127.0.0.1";

const app = createApp();

app.listen(port, host, () => {
  console.log(`MarqueeFlow API listening on http://${host}:${port}`);
});
