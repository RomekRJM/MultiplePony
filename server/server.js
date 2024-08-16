import path from "path";
import express from "express";
import http from "http";
import { Server } from "socket.io";
import fs from "fs";
import createPicoSocketClient from "./client.js";

const createPicoSocketServer = ({
                                    assetFilesPath,
                                    htmlGameFilePath,
                                }) => {
    // required "create the webserver" logic
    const app = express();
    const server = http.createServer(app);
    const io = new Server(server);

    // read in the html file now, so we can append some script tags for the client side JS
    const htmlFileData = fs.readFileSync(htmlGameFilePath);
    const htmlFileTemplate = htmlFileData.toString();

    // build script tags to inject in the head of the document
    const clientSideCode = `
      <script src="/socket.io/socket.io.js"></script>
      <script defer>
        const createPicoSocketClient = ${createPicoSocketClient.toString()};
        createPicoSocketClient();
      </script>
    </head>
  `;

    // add the client side code
    const modifiedTemplate = htmlFileTemplate.replace("</head>", clientSideCode);

    // host the static files
    app.use(express.static(path.join(process.cwd(), assetFilesPath)));
    app.use((__req, res) => {
        // by default serve the modified html game file
        console.log("clientSideCode", clientSideCode);
        return res.send(modifiedTemplate);
    });

    // host on port 5000
    const PORT = process.env.PORT || 5000;
    server.listen(PORT, () =>
        console.log(`Server Running http://localhost:${PORT}`)
    );

    return { app, server, io };
}

export default createPicoSocketServer;