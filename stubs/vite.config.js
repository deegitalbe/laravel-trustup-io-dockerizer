import { defineConfig, loadEnv } from 'vite';
import laravel from 'laravel-vite-plugin';

export default ({ mode }) =>  {
    let server = undefined;
    const isLocal = mode === "development";

    if (isLocal) {
        process.env = {...process.env, ...loadEnv(mode, process.cwd())};
        const port = parseInt(process.env.VITE_PORT)
        server = {
            host: '0.0.0.0',
            port,
            hmr: {
                host: "localhost",
            }
        }
    }
    
    return defineConfig({
        plugins: [
            laravel({
                input: ['resources/css/app.css', 'resources/js/app.js'],
                refresh: true,
            }),
        ],
        server
    });
}

