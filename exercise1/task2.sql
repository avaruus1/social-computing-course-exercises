SELECT COUNT(*)
FROM users U
         LEFT JOIN comments C ON U.id = C.user_id
         LEFT JOIN posts P ON U.id = P.user_id
         LEFT JOIN reactions R ON U.id = R.user_id
WHERE C.id IS NULL
  AND P.id IS NULL
  AND R.id IS NULL;

