-- In 13.sql, write a SQL query to list the names of all people who starred in a movie in which Kevin Bacon also starred.

--     Your query should output a table with a single column for the name of each person.
--     There may be multiple people named Kevin Bacon in the database. Be sure to only select the Kevin Bacon born in 1958.
--     Kevin Bacon himself should not be included in the resulting list.

SELECT name

FROM people
    INNER JOIN stars ON people.id = stars.person_id

WHERE stars.movie_id IN (
    SELECT movie_id

    FROM people
        INNER JOIN stars ON people.id = stars.person_id

    WHERE people.name = "Kevin Bacon"
) AND NOT people.name = "Kevin Bacon"
