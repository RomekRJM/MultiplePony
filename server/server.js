import path from "path";
import express from "express";
import http from "http";
import { Server } from "socket.io";
import fs from "fs";
import createPicoSocketClient from "./client.js";
import crypto from "crypto";

const getOrCreateName = (req) => {
    if (req.query.name) {
        return req.query.name;
    }

    let colors = [
		"red", "teal", "orange", "magenta", "blue", "green", "purple", "pink", "black", "brown", "white", "yellow",
		"grey", "olive", "amber", "azure", "beige", "violet", "fuchsia", "gold", "silver"
	];

	let color = colors[Math.floor(Math.random() * colors.length)];
	let number = Math.floor(Math.random() * 10);

	return color + number;
};

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
    app.use((req, res) => {
        // by default serve the modified html game file
        return res.send(modifiedTemplate.replace('CURRENT_PLAYER_NAME', getOrCreateName(req)));
    });

    // host on port 5000
    const PORT = process.env.PORT || 5000;
    server.listen(PORT, () =>
        console.log(`Server Running http://localhost:${PORT}`)
    );

    return { app, server, io };
}

export default createPicoSocketServer;