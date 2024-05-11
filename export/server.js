const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
    // Set the content type
    res.setHeader('Content-Type', 'text/html');

    // Set Cross-Origin Isolation and SharedArrayBuffer headers
    res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');

    // Function to serve static files
    const serveStaticFile = (filePath, contentType) => {
        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(500);
                return res.end('Error loading file');
            }
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(data);
        });
    };

    // Check if the request is for the root path
    if (req.url === '/') {
        // Read the HTML file
        serveStaticFile(path.join(__dirname, 'CardanoAuth.html'), 'text/html');
    } else {
        // Serve static files from the same directory
        const filePath = path.join(__dirname, req.url);
        const extname = path.extname(filePath);
        let contentType = 'text/html';

        // Set content type based on file extension
        switch (extname) {
            case '.js':
                contentType = 'text/javascript';
                break;
            case '.css':
                contentType = 'text/css';
                break;
            case '.png':
                contentType = 'image/png';
                break;
            // Add more cases for other file types if needed
        }

        // Serve the static file
        serveStaticFile(filePath, contentType);
    }
});

const PORT = process.env.PORT || 3000;

server.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
