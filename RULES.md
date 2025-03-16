# General
* prefer TDD/BDD flow
* try to write ruby code according to POODR
* prefer POROs
* any significant features should be put in `README.md`
* any upcoming features will be in `TODO.md`

# Rails
* prefer rake tasks over other entrance points for running one off commands
* use `rails generate migration` for any database migration creation
* all credentials and secrets and keys are in Rails.application.credentials.
* use a standard linter if there's a linter error - `bin/rubocop -A`
* in general try to do things "the rails way"

# Testing
* prefer minitest for simpler PORO leaning tests
* prefer real objects and vcr cassettes over mocks, mocks are considered harmful
* when manually testing together in the dev environment, give the test plan first, then run the command that will run, then check the console logs for information
* when using `test/vcr_cassettes` rm the cassette before run if we're debugging a test or it will lock in the wrong value