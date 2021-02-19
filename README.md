# pass-bc

A [pass](https://www.passwordstore.org/) extension for managing TOTP Backup Codes

Forked from [pass-botp](https://github.com/msmol/pass-botp)

This version supports adding TOTP Backup Codes to the same file which contains the password

## Usage

```
$ pass bc
Usage: pass bc [--clip,-c] pass-name
```

## Example

`pass-bc` assumes your backup codes are stored line by line in the password file, enclosed with `## pass-bc`.

E.g. `password-file.gpg`:

```
somepassword

some other metadate

## pass-bc
111 111
222 222
333 333
444 444
## pass-bc
```

pass-bc will provide you with the first non-commented line, and then comment that line out:

```
$ pass botp password-file
111 111
```

password-file will now be:

```
somepassword

some other metadate

## pass-bc
# 111 111
222 222
333 333
444 444
## pass-bc
```

On each subsequent run, `pass-bc` will give the next available backup code (in this case, `222 222`) until none remain.

## Copying to clipboard

Simply add `-c` or `--clip`

```
$ pass bc -c password-file
Copied Backup code for password-file to clipboard. Will clear in X seconds.
```
