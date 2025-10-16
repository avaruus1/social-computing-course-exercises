SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
FROM posts IP
         LEFT JOIN comments IC ON IC.post_id = IP.id
         LEFT JOIN users IU ON IU.id = IC.user_id
WHERE IU.id != 539
  AND IP.id IN (SELECT comments.post_id
                FROM comments
                WHERE comments.user_id = 539)
UNION ALL
SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
FROM posts IP
         LEFT JOIN reactions IR ON IR.post_id = IP.id
         LEFT JOIN users IU ON IU.id = IR.user_id
WHERE IU.id != 539
  AND IP.id IN (SELECT reactions.post_id
                FROM reactions
                WHERE reactions.user_id = 539);

SELECT P.*, SUM(value) v
FROM posts P
         LEFT JOIN comments C ON P.id = C.post_id
         LEFT JOIN reactions R ON P.id = R.post_id,
     (SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
      FROM posts IP
               LEFT JOIN comments IC ON IC.post_id = IP.id
               LEFT JOIN users IU ON IU.id = IC.user_id
      WHERE IU.id != 539
        AND IP.id IN (SELECT comments.post_id
                      FROM comments
                      WHERE comments.user_id = 539)
      UNION ALL
      SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
      FROM posts IP
               LEFT JOIN reactions IR ON IR.post_id = IP.id
               LEFT JOIN users IU ON IU.id = IR.user_id
      WHERE IU.id != 539
        AND IP.id IN (SELECT reactions.post_id
                      FROM reactions
                      WHERE reactions.user_id = 539))
WHERE C.user_id = uid
   OR R.user_id = uid
GROUP BY P.id, P.created_at
ORDER BY v DESC, P.created_at DESC
LIMIT 5;

SELECT followed_id
FROM follows
WHERE follower_id = 539;

SELECT P.*, SUM(value) v
FROM posts P
         LEFT JOIN comments C ON P.id = C.post_id
         LEFT JOIN reactions R ON P.id = R.post_id,
     (SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
      FROM posts IP
               LEFT JOIN comments IC ON IC.post_id = IP.id
               LEFT JOIN users IU ON IU.id = IC.user_id
      WHERE IU.id != 539
        AND IP.id IN (SELECT comments.post_id
                      FROM comments
                      WHERE comments.user_id = 539)
      UNION ALL
      SELECT DISTINCT IU.id uid, COUNT(DISTINCT IP.id) value
      FROM posts IP
               LEFT JOIN reactions IR ON IR.post_id = IP.id
               LEFT JOIN users IU ON IU.id = IR.user_id
      WHERE IU.id != 539
        AND IP.id IN (SELECT reactions.post_id
                      FROM reactions
                      WHERE reactions.user_id = 539)
        AND uid IN (SELECT followed_id FROM follows WHERE follower_id = 539))
WHERE C.user_id = uid
   OR R.user_id = uid
GROUP BY P.id, P.created_at
ORDER BY v DESC, P.created_at DESC
LIMIT 5;

SELECT username, id
FROM users
WHERE username = 'starboy99'
   OR username = 'DancingDolphin'
   OR username = 'blogger_bob';


SELECT *
FROM users
WHERE username = 'testerman';