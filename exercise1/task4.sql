SELECT CNT.user_id, MAX(CNT.content_cnt) size
FROM (SELECT U.id             user_id,
             COUNT(P.content) content_cnt
      FROM users U
               INNER JOIN posts P ON U.id = P.user_id
      GROUP BY U.id, P.content
      UNION ALL
      SELECT U.id             user_id,
             COUNT(C.content) content_cnt
      FROM users U
               INNER JOIN comments C ON U.id = C.user_id
      GROUP BY U.id, C.content) CNT
GROUP BY CNT.user_id
HAVING size >= 3;



