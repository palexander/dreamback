## Dreamback is the easiest way to automate your backups on dreamhost.
Dreamhost does not guarantee their backups of your users (though they've saved me with backups before), so it's best to run backups yourself.

### This is beta quality software. Please report [issues](https://github.com/palexander/dreamback/issues) if you have them.

## Using Dreamback is easy:

1. Create a user on dreamhost to schedule your backups
2. Log in with your new user
3. `gem install dreamback`
4. `dreamback`
5. Answer the questions to setup your automated backup

## Security

**IMPORTANT NOTE:** Dreamback relies on ssh keys to login to remote accounts, both for accounts you'd like to back up and the backup account that Dreamhost provides. If the keys don't exist you will be prompted to create them. If the account you are using to run the Dreamback process is compromised, it will have access to all of the accounts you have keys for.

**For this reason, I highly recommend you create a special account for running the backup process with a very sophisticated password and all security options provided by Dreamhost enabled**. This won't eliminate all security threats, but hopefully it will minimize the possibility of a breach that would affect all of your accounts.

## Installation

    gem install dreamback

## Usage

Run `dreamback` to configure automated backups.
Run `dreamback backup` to immediately run a backup.

## Contributing

I'm happy to take pull or feature requests. Use the Github issue tracker if you have suggestions or need help.