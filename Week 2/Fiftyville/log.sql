-- Keep a log of any SQL queries you execute as you solve the mystery.

SELECT caller FROM phone_calls; -- See what text is there (it's phone numbers)
SELECT activity FROM bakery_security_logs; -- See the activity (enters and exit)

SELECT crime_scene_reports.description, bakery_security_logs.activity, bakery_security_logs.license_plate
FROM crime_scene_reports, bakery_security_logs
WHERE crime_scene_reports.year = 2024 AND crime_scene_reports.month = 7 AND crime_scene_reports.day = 28
AND bakery_security_logs.year = 2024 AND bakery_security_logs.month = 7 AND bakery_security_logs.day = 28; --Everything on the day of the incident.

SELECT crime_scene_reports.description, bakery_security_logs.activity, bakery_security_logs.license_plate
FROM crime_scene_reports, bakery_security_logs
WHERE crime_scene_reports.year = 2024 AND crime_scene_reports.month = 7 AND crime_scene_reports.day = 28
AND bakery_security_logs.year = 2024 AND bakery_security_logs.month = 7 AND bakery_security_logs.day = 28
AND description LIKE "%CS50 duck%"; -- an addon to limit it to The Crime

SELECT name, transcript
FROM interviews
WHERE transcript LIKE "%The bakery%"; -- Read interviews

SELECT activity, license_plate, minute
FROM bakery_security_logs
WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25; --Gather all the potential theif license plates
-- it's one of these
-- | exit     | 5P2BI95       | 16     |
-- | exit     | 94KL13X       | 18     |
-- | exit     | 6P58WS2       | 18     |
-- | exit     | 4328GD8       | 19     |
-- | exit     | G412CB7       | 20     |
-- | exit     | L93JTIZ       | 21     |
-- | exit     | 322W7JE       | 23     |
-- | exit     | 0NTHK55       | 23     |

SELECT caller
FROM phone_calls
WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60000; -- Well I was planning to see their phone number but oh well. Inspired a new plan tho

SELECT name
FROM people
WHERE license_plate IN (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND minute > 15 AND activity = "exit"
)
AND phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60000
); -- hopefully Solve, but no
-- it's one of these people
-- +---------+
-- |  name   |
-- +---------+
-- | Vanessa |
-- | Barry   |
-- | Sofia   |
-- | Diana   |
-- | Kelsey  |
-- | Bruce   |
-- +---------+

SELECT description
FROM crime_scene_reports
WHERE year = 2024 AND month = 7 AND day = 28 AND street LIKE "%Humphrey%"; -- was hoping to see another crime or something

SELECT phone_calls.receiver, people.name--hoping to one shot it
FROM phone_calls, people
WHERE phone_calls.caller AND people.phone_number IN (
    SELECT phone_number
    FROM people
    WHERE license_plate IN (
        SELECT license_plate
        FROM bakery_security_logs
        WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit"
    )
    AND phone_number IN (
        SELECT caller
        FROM phone_calls
        WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60000
    )
);


SELECT *  --hopping to get plane-ticket levels of withdraw
FROM atm_transactions
WHERE year = 2024 AND month = 7 AND day = 28 AND account_number IN (
    SELECT account_number
    FROM bank_accounts
    WHERE person_id IN (
        SELECT id
        FROM people
        WHERE license_plate IN (
            SELECT license_plate
            FROM bakery_security_logs
            WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit"
        )
        AND phone_number IN (
            SELECT caller
            FROM phone_calls
            WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60000
        )
    )
);


SELECT name
FROM people
WHERE license_plate IN (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND minute > 15 AND activity = "exit"
) AND license_plate IN (
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2024 AND month = 7 AND day = 28 AND hour <= 10 AND activity = "entrance"
)
AND phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60
); --seeing if in seconds
-- +--------+
-- |  name  |
-- +--------+
-- | Sofia  |
-- |   |
-- | Kelsey |
-- |   |
-- +--------+

.schema --checking to see if I missed something

SELECT name
FROM people
WHERE phone_number IN (
    SELECT receiver
    FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60 AND caller IN(
        SELECT caller
        FROM phone_calls
        WHERE caller IN (
            SELECT phone_number
            FROM people
            WHERE license_plate IN (
                SELECT license_plate
                FROM bakery_security_logs
                WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit"
            )
        )
    )
) AND passport_number IN (
    SELECT passport_number
    FROM passengers
    WHERE flight_id IN (
        SELECT id
        FROM flights
        WHERE origin_airport_id IN (
            SELECT id
            FROM airports
            WHERE city LIKE "fiftyville%"
        )
        AND year = 2024 AND month = 7 AND day = 29
    )
); --Trying to reverse engineer it

SELECT id, hour
FROM flights
WHERE origin_airport_id IN (
    SELECT id
    FROM airports
    WHERE city LIKE "fiftyville%"
)
AND year = 2024 AND month = 7 AND day = 29
ORDER BY hour; --To know what the earliest flight out is

SELECT name
FROM people
WHERE phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60 AND caller IN(
        SELECT phone_number
        FROM people
        WHERE license_plate IN (
            SELECT license_plate
            FROM bakery_security_logs
            WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit"
        )
    )
)
AND passport_number IN (
    SELECT passport_number
    FROM passengers
    WHERE flight_id IN (
        SELECT id
        FROM flights
        WHERE origin_airport_id IN (
            SELECT id
            FROM airports
            WHERE city LIKE "fiftyville%"
        )
        AND year = 2024 AND month = 7 AND day = 29 AND hour = 8
    )
);
-- +--------+
-- |  name  |
-- +--------+
-- | Sofia  |
-- | Kelsey |
-- |   |
-- +--------+


SELECT *  --hopping to get plane-ticket levels of withdraw from someone whos friend is on the plane
FROM atm_transactions
WHERE year = 2024 AND month = 7 AND day = 28 AND account_number IN (
    SELECT account_number
    FROM bank_accounts
    WHERE person_id IN (
        SELECT id
        FROM people
        WHERE phone_number IN (
            SELECT receiver
            FROM phone_calls
            WHERE caller IN (
                SELECT phone_number
                FROM people
                WHERE license_plate IN (
                    SELECT license_plate
                    FROM bakery_security_logs
                    WHERE year = 2024 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit"
                )
                AND phone_number IN (
                    SELECT caller
                    FROM phone_calls
                    WHERE year = 2024 AND month = 7 AND day = 28 AND duration < 60000
                )
                AND passport_number IN (
                    SELECT passport_number
                    FROM passengers
                    WHERE flight_id IN (
                        SELECT id
                        FROM flights
                        WHERE origin_airport_id IN (
                            SELECT id
                            FROM airports
                            WHERE city LIKE "fiftyville%"
                        )
                        AND year = 2024 AND month = 7 AND day = 29 AND hour = 8
                    )
                )
            )
            AND year = 2024 AND month = 7 AND day = 28 AND duration < 60000
        )
    )
);

-- 16654966 had the highest withdrawl

SELECT people.name --nab them
FROM people
    INNER JOIN bank_accounts ON people.id = bank_accounts.person_id
WHERE bank_accounts.account_number = 16654966;

SELECT name
FROM people
WHERE phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE receiver IN (
        SELECT phone_number
        FROM people
        WHERE name = "Pamela"
    )
    AND year = 2024 AND month = 7 AND day = 28 AND duration < 60000
);
-- Well. It isn't them
-- 40665580 withdrew twice from the street of the crime

SELECT people.name --nab them
FROM people
    INNER JOIN bank_accounts ON people.id = bank_accounts.person_id
WHERE bank_accounts.account_number = 40665580;
-- Charles

SELECT name
FROM people
WHERE phone_number IN (
    SELECT caller
    FROM phone_calls
    WHERE receiver IN (
        SELECT phone_number
        FROM people
        WHERE name = "Jack"
    )
    AND year = 2024 AND month = 7 AND day = 28 AND duration < 60000
);
-- 69638157 SHOULD have been the only number in that query. Woops
SELECT people.name --nab them
FROM people
    INNER JOIN bank_accounts ON people.id = bank_accounts.person_id
WHERE bank_accounts.account_number = 69638157;
-- Jack

SELECT city
FROM airports
WHERE id IN (
    SELECT destination_airport_id
    FROM flights
    WHERE origin_airport_id IN (
        SELECT id
        FROM airports
        WHERE city LIKE "fiftyville%"
    )
    AND year = 2024 AND month = 7 AND day = 29 AND hour = 8
);
