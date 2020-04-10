# Fennel and TIC-80 game template
Boilerplate code for a simple [TIC-80](https://tic.computer/) game using [Fennel](https://fennel-lang.org/) lisp.

## Requeriments
- GNU/Linux or OSX
- Install `tic80` and `fennel` packages from your package manager

## Usage
### Development
- `$ ./utils.sh -c` to compile all Fennel source files;
- `$ ./utils.sh -r` to run the compiled file with TIC-80;
- `$ ./utils.sh -c -r` to do both at once;
- If you need to add more files, create them inside the `source` directory and include the source files in `SOURCE_FILES` array inside `utils.sh`.

### Export to HTML
- Run your game with `$ ./utils.sh -r`;
- Press `ESC` to open the prompt;
- Enter `export html` and save the zip file wherever you want, for example in `build/`;
- Quit the game and unzip the files.

### Test the game on the browser
If you want to test the game you have to serve the exported files. In this example we will use python, but you can chose whatever method you prefer.

- Go to the terminal and change directory (`cd`) to where you unzipped the files;
- Using python enter `$ pythom -m http.server`;
- Visit <http://0.0.0.0:8000/> on your browser to test your game.

