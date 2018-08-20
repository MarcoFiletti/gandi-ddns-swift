# Gandi DynDNS Updater

<p align="center">
  <a href="https://swift.org" target="_blank">
    <img src="https://img.shields.io/badge/swift-4.2-brightgreen.svg" alt="Swift 4.2">
  </a>
  <a href="https://travis-ci.org/MarcoFiletti/gandi-ddns-swift" target="_blank">
    <img src="https://travis-ci.org/MarcoFiletti/gandi-ddns-swift.svg" alt="Build status">
  </a>
  <a href="https://developer.apple.com/swift/" target="_blank">
    <img src="https://img.shields.io/badge/Platforms-macOS%20%B7%20Linux%20-lightgray.svg" alt="For macOS and Linux">
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
  </a>
</p>


`GandiDDNS` updates Gandi's DNS records via the [LiveDNS API](http://doc.livedns.gandi.net), pointing them to the current machine.

The executable can be compiled and moved in the current folder like this:
`swift build -c release && mv -v .build/release/GandiDDNS .`

Upon first run, it will ask for the Gandi domain (e.g. example.com) and API key (an alphanumeric string).

`./GandiDDNS`

If the domain and key were accepted by Gandi, it will create a `config.json` file with a simple configuration that will point `@` and `www` records to the current machine for both IPv4 and IPv6 addresses.

More configuration examples can be seen below in [Config Examples](#config-examples)

## Usage:

`./GandiDDNS [options] [config]`

where config is a json file containing a configuration (defaults to `config.json`)

**Options**:

`-n` dry run: does not actually modify records.

`-v` verbose: prints every single step.

`-q` quiet: prints nothing. Use return codes to detect errors (0 means everything was successful).

For example, `./GandiDDNS -vn config2.json` starts a dry, verbose run using `config2.json`; use this to tests configurations before deployment.


### Config Examples

Config files contain a list of objects called `domains`. Each object in it has the fields `apiKey`, `name` and `subdomains`. `subdomains` is a list of objects with `name` (DNS Record name) and `type` (`A` for IPv4 or `AAAA` for IPv6). Optionally, a subdomain can contain an `ip` field which will be used to point to record to (instead of using the machine's current IP).

This is a very basic config with only `www` and `@` entries for IPv4

```
{
  "domains" : [
    {
      "name" : "example.com",
      "apiKey" : "abcdefg123456",
      "subdomains" : [
        {
          "name" : "www",
          "type" : "A"
        },
        {
          "name" : "@",
          "type" : "A"
        }
      ]
    }
  ]
}
```

---

A config can be used to control multiple domains pointing to the same machine, like this

```
{
  "domains" : [
    {
      "name" : "example.com",
      "apiKey" : "abcdefg123456",
      "subdomains" : [
        {
          "name" : "www",
          "type" : "A"
        },
        {
          "name" : "@",
          "type" : "A"
        },
        {
          "name": "static",
          "type": "A",
          "ip": "123.123.123.123"
        }
      ]
    },
    {
      "name" : "example2.com",
      "apiKey" : "000000aaaaaaa",
      "subdomains" : [
        {
          "name" : "www",
          "type" : "A"
        },
        {
          "name" : "@",
          "type" : "A"
        },
        {
          "name" : "ipv6",
          "type" : "AAAA"
        }
      ]
    }
  ]
}
```

in the example, we used forced an IPv4 of `123.123.123.123` for static.example.com an we included an IPv6 record only for ipv6.example2.com. 

### Testing

Developers can test the package with `swift test`. To do a full test using real data, edit the `Tests/GandiDDNSTests/DomainDetails.swift` and include a real API name and key. Swift testing will then perform a dry run using the specified details and various mock configs.

Remember to skip the `DomainDetails.swift` file in git to avoid accidental pushing of real API details:

`git update-index --skip-worktree Tests/GandiDDNSTests/DomainDetails.swift`
