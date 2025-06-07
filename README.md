<div align="center">
<pre>
╔════════════════════════════════╗
║                                ║
║   ████   ████  ██  ██ ██  ██   ║
║  ██     ██     ██  ██ ██  ██   ║
║  ██      ████  ██  ██ ██  ██   ║
║  ██         ██  ████  ██  ██   ║
║   ████  █████    ██    ████    ║
║                                ║
║                                ║
╚════════════════════════════════╝
</pre>
</div>
<p align="center">
 <em>Unleashing CSV Power, One Line at a Time!</em>
</p>
<p align="center">
 <img src="https://img.shields.io/github/license/Tilo-K/csvu?style=flat&logo=opensourceinitiative&logoColor=white&color=0080ff" alt="license">
 <img src="https://img.shields.io/github/last-commit/Tilo-K/csvu?style=flat&logo=git&logoColor=white&color=0080ff" alt="last-commit">
 <img src="https://img.shields.io/github/languages/top/Tilo-K/csvu?style=flat&color=0080ff" alt="repo-top-language">
 <img src="https://img.shields.io/github/languages/count/Tilo-K/csvu?style=flat&color=0080ff" alt="repo-language-count">
</p>
<br>

## Overview

The csvu is a dynamic CSV utility designed to streamline data handling. It effectively parses and presents CSV files in a user-friendly tabular format, with automatic delimiter recognition and data validation. Providing a precise terminal dimension fetcher, csvu ensures seamless cross-platform compatibility. Ideal for developers and data enthusiasts seeking robust, reliable, and easy-to-navigate data solutions.

## Example Output

<pre>
-----------------------------------------------------------------------------------
|country |latitude   |longitude   |name                                           |
-----------------------------------------------------------------------------------
|AD      |42.546245  |1.601554    |Andorra                                        |
|AE      |23.424076  |53.847818   |"United Arab Emirates"                         |
|AF      |33.93911   |67.709953   |Afghanistan                                    |
|AG      |17.060816  |-61.796428  |"Antigua and Barbuda"                          |
|AI      |18.220554  |-63.068615  |Anguilla                                       |
|AL      |41.153332  |20.168331   |Albania                                        |
|AM      |40.069099  |45.038189   |Armenia                                        |
|AN      |12.226079  |-69.060087  |"Netherlands Antilles"                         |
|AO      |-11.202692 |17.873887   |Angola                                         |
|AQ      |-75.250973 |-0.071389   |Antarctica                                     |
|VC      |12.984305  |-61.287228  |"Saint Vincent and the Grenadines"             |
|VE      |6.42375    |-66.58973   |Venezuela                                      |
|VG      |18.420695  |-64.639968  |"British Virgin Islands"                       |
|VI      |18.335765  |-64.896335  |"U.S. Virgin Islands"                          |
|VN      |14.058324  |108.277199  |Vietnam                                        |
|VU      |-15.376706 |166.959158  |Vanuatu                                        |
|WF      |-13.768752 |-177.156097 |"Wallis and Futuna"                            |
|WS      |-13.759029 |-172.104629 |Samoa                                          |
|XK      |42.602636  |20.902977   |Kosovo                                         |
|YE      |15.552727  |48.516388   |Yemen                                          |
|YT      |-12.8275   |45.166244   |Mayotte                                        |
|ZA      |-30.559482 |22.937506   |"South Africa"                                 |
|ZM      |-13.133897 |27.849332   |Zambia                                         |
|ZW      |-19.015438 |29.154857   |Zimbabwe                                       |
-----------------------------------------------------------------------------------
</pre>

---

## Project Structure

```sh
└── csvu/
    ├── LICENSE
    ├── build.zig
    ├── build.zig.zon
    ├── demo.csv
    └── src
        ├── csv.zig
        ├── main.zig
        ├── root.zig
        └── term.zig
```

---

## Getting Started

### Prerequisites

Before getting started with csvu, ensure your runtime environment meets the following requirements:

- **Programming Language:** Zig
- **Zig Version:** 0.14.0 or later

### Installation

Install csvu using one of the following methods:

**Build from source:**

1. Clone the csvu repository:

```sh
❯ git clone https://github.com/Tilo-K/csvu
```

2. Navigate to the project directory:

```sh
❯ cd csvu
```

3. Build the project using Zig:

zig build --release=fast

### Usage

Run csvu using the following command:
csvu [file]

---

## Project Roadmap

- [X] **`Print basic tables`**: <strike>Be able to print basic tables.</strike>
- [ ] **`Search in rows`**: Implement a basic search feature for rows.
- [ ] **`Colors`**: Implement colored output for better readability.

---

## Contributing

- **💬 [Join the Discussions](https://github.com/Tilo-K/csvu/discussions)**: Share your insights, provide feedback, or ask questions.
- **🐛 [Report Issues](https://github.com/Tilo-K/csvu/issues)**: Submit bugs found or log feature requests for the `csvu` project.
- **💡 [Submit Pull Requests](https://github.com/Tilo-K/csvu/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your github account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.

   ```sh
   git clone https://github.com/Tilo-K/csvu
   ```

3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.

   ```sh
   git checkout -b new-feature-x
   ```

4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.

   ```sh
   git commit -m 'Implemented new feature x.'
   ```

6. **Push to github**: Push the changes to your forked repository.

   ```sh
   git push origin new-feature-x
   ```

7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!

</details>

<details closed>
<summary>Contributor Graph</summary>
<br>
<p align="left">
   <a href="https://github.com{/Tilo-K/csvu/}graphs/contributors">
      <img src="https://contrib.rocks/image?repo=Tilo-K/csvu">
   </a>
</p>
</details>


---
