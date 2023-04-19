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
