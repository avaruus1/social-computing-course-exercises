SELECT P.id,
       COUNT(DISTINCT C.id)                          comments,
       COUNT(DISTINCT R.id)                          reactions,
       (COUNT(DISTINCT C.id) + COUNT(DISTINCT R.id)) engagement
FROM users U
         INNER JOIN posts P ON U.id = P.user_id
         LEFT JOIN comments C ON P.id = C.post_id
         LEFT JOIN reactions R ON P.id = R.post_id
GROUP BY P.id
ORDER BY engagement DESC
LIMIT 5;
