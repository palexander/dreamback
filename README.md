# Dreamback

Dreamback is the easiest way to automate your backups on dreamhost. Dreamhost does not guarantee their backups of your users (though they've saved me with backups before), so it's best to run backups yourself.

Using Dreamback is easy:
1. Create a user on dreamhost to schedule your backups
2. Log in with your new user
3. `gem install dreamback`
4. `dreamback`
5. Answer the questions to setup your automated backup

## Installation

Add this line to your application's Gemfile:

    gem 'dreamback'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dreamback

## Usage

Run `dreamback` to configure automated backups.
Run `dreamback backup` to immediately run a backup.

## Contributing

I'm happy to take pull or feature requests. Use the Github issue tracker if you have suggestions or need help.