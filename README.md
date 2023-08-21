<h1 align="center">
  <br>
  <img src="Readme Images/Icon.png" alt="Phoenix app icon" width="100" height="100"/>
  <br>
  <b>Phoenix Game Launcher</b>
  <br>
</h1>

<p align="center">Phoenix is an open-source game launcher for macOS, written in SwiftUI. This launcher was inspired by projects like <a href="https://playnite.link" target="_blank">Playnite</a> and <a href="https://lutris.net" target="_blank">Lutris</a>, and supports any game which can be launched from the command line. (So basically all of them!) It was designed to be small, fast, and not overly complicated. Phoenix is available on GitHub under the <a href="License.txt" target="_blank">MIT license</a></p>

<img src="Readme Images/phoenixdark.webp" alt="Screenshot of the app"/>

## Usage

To run this launcher, your Mac must be on at least macOS 13.0 (Ventura).

Download the [latest release](https://github.com/Shock9616/Phoenix/releases) from the releases page and install the app like you would with any other. The first time you open the app, you will get an alert saying that your Mac can't check the app for malicious software. This is because I'm a broke university student who can't afford an Apple Developer Program membership. Open up the app anyways :)

Wen you first open the app, it'll look something like this:
<img src="Readme Images/phoenixplaceholder.webp" alt="Screenshot of the app"/>


You can add a game by clicking the '+' button in the toolbar. Fill in as much information as you can. It should look something like this after that:
<img src="Readme Images/phoenixnms.webp" alt="Screenshot of the app"/>

To run the game, you need at the VERY least a name and a launcher command. All the other things are for making the launcher look nicer. Once you've added a game you can delete the placeholder game by right-clicking and selecting 'Delete Game'. You can edit a game you've already added by clicking the pencil button next to the play button. 

Once you have a game and it's launcher command is configured, you can hit the play button and it will open up!

## Launcher commands:

I know that not everyone has used the terminal before, so here are some templates for some common places to find games:

#### App Store/Regular Mac games:

```
open -a "<App Name>"
```

or

```
open ~/Applications/<App Name Here>.app
```

#### Steam games:

Steam games are now automatically detected by Phoenix! But, on the off chance that you want to change it or need to enter it yourself, here's the format to use:

```
open steam://run/<steam app id here>
```

You can find your game's id by going to [SteamDB](steamdb.info) and searching for your game. The app id will be in the leftmost column.

#### Parallels

If you didn't know, Applications installed in Parallels have Mac apps that act as launchers in `~/Applications (Parallels)/<VM Name> Applications/`, so any Windows game you play via Parallels can be launched like this (Using my VM called 'Windows 11' as an example):

```
open ~/Applications\ (Parallels)/Windows\ 11\ Applications/<game name>.exe.app
```

#### Crossover

Crossover apps are installed to `~/Applications/CrossOver` so they can be launched like this:

```
open ~/Applications/CrossOver/<game name>.app
```

#### Emulated games:

There isn't a set formula for emulated games, since the games are all run by different apps. That said, most (not all) will work with one of these options:

```
open /path/to/rom/file

For example, this command opens Metroid Prime Hunters in DeSuME for me:

open ~/Documents/Gaming/ROMs/NDS/Metroid\ Prime\ Hunters.nds
```

or 

```
open /Applications/<emulator name here>.app/Contents/MacOS/<emulator name> /path/to/rom/file

For example, this command opens Metroid Dread in Ryujinx for m:

open /Applications/Ryujinx.app/Contents/MacOS/Ryujinx ~/Documents/Gaming/ROMs/Switch/Metroid\ Dread.nsp
```

or 

```
/Applications/<emulator name here>.app/Contents/MacOS/<emulator name> "/path/to/rom/file"

For example, this command opens Red Dead Revolver in AetherSX2 for me:

/Applications/AetherSX2.app/Contents/MacOS/AetherSX2 "/Volumes/Crucial X6/Games/PS2/Red Dead Revolver/Red Dead Revolver.iso"
```

## Building

If you want to build this app for yourself, just download this repository

```bash
git clone git@github.com:Shock9616/Phoenix.git
```

then open `Phoenix.xcodeproj` in Xcode. You will first have to update the `Team` field in the `Signing and Capabilities` section of `Targets > Phoenix` in the main Project file. You can then create a `.app` file by going to `Product > Archive` in the menu bar, clicking `Distribute App`, selecting `Copy App` and then saving the folder somewhere easy to find like your desktop. The app will be inside the folder and you can copy it into your applications folder and begin using it!

## Updates

If you want to be notified when new updates are released here, make sure you "watch" this repository at the top of the page. You can be notified of only new releases by clicking the arrow next to the button, selecting "Custom", and then selecting "Releases" and then "Apply"

## Contact

If you need to contact us for anything, you can join our [Discord Server](https://discord.gg/Q8TQ6rYfGQ). There you can ask the devs for help if you are having any issues using our app, and you will be the first to know when there are new releases!

## Contributing

We would love to have you on the team! There are lots of ways to contribute, you can:

- Contribute code

- Help with UI design

- Help test and find bugs

- Submit feature requests

- Pretty much anything else you can think of!

You don't need to be a developer to help make this project the best it can be! Even something as simple as letting us know when something doesn't work as expected is incredibly helpful! To contribute you can submit bug reports to our Issues section here on GitHub, or you can join our [Discord Server](https://discord.gg/Q8TQ6rYfGQ) to discuss ideas, collaborate on code, etc.

We're very excited to see where this project goes, and we would love for the development of this app to be the catalyst for a new community of people who love gaming on Macs!

## Credits

* App Icon was generated by [DALL·E 2](https://openai.com/dall-e-2/) (I'm not an artist 😅)

* As much as I'm embarassed to say it, there is code in this project written by [ChatGPT](https://openai.com). (I said I don't know much Swift 🤷‍♂️😅)
