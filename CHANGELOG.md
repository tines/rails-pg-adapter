## [0.1.14] - 2024-02-06

- Capture the database system is in recovery mode error

## [0.1.13] - 2023-05-09

- Use throw_away! instead and capture state of transaction and re-raise accordingly

## [0.1.12] - 2023-05-08

- Slight refactor and reduce multiple disconnect attempts

## [0.1.11] - 2023-05-08

- Attempt a re-connect before a retry

## [0.1.10] - 2023-05-04

- Handle Connection refused

## [0.1.9] - 2023-05-04

- Retry on too many connections error as well

## [0.1.8] - 2023-04-28

- Make retry on ActiveRecord::NoDatabaseError stricter

## [0.1.7] - 2023-04-21

- Simplify connection management and introduce upper bound to retries

## [0.1.6] - 2023-04-19

- Disconnect and remove connection when in read-only

## [0.1.5] - 2023-04-19

- Retry queries when not in transaction

## [0.1.4] - 2023-04-04

- Rescue and recover from `ActiveRecord::ConnectionNotEstablished`

## [0.1.3] - 2023-04-04

- Bug fix: Always prepend the patch on boot to avoid issues with loading the monkey patch on some Rails installations

## [0.1.2] - 2023-03-29

- Bug fix: Ensure RailsPgAdapter constant is discoverable

## [0.1.1] - 2023-03-29

- Initial release
