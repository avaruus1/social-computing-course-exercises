-- min
SELECT AVG(ROUND(86400 * (JULIANDAY(C.created_at) - JULIANDAY(P.created_at)))) min_comment_time
FROM posts P
         INNER JOIN comments C ON P.id = C.post_id
         INNER JOIN (SELECT IC.post_id pid, MIN(IC.created_at) comment_release_time
                     FROM comments IC
                     GROUP BY IC.post_id) IC ON P.id = IC.pid
WHERE C.created_at = IC.comment_release_time;

-- max
SELECT AVG(ROUND(86400 * (JULIANDAY(C.created_at) - JULIANDAY(P.created_at)))) max_comment_time
FROM posts P
         INNER JOIN comments C ON P.id = C.post_id
         INNER JOIN (SELECT IC.post_id pid, MAX(IC.created_at) comment_release_time
                     FROM comments IC
                     GROUP BY IC.post_id) IC ON P.id = IC.pid
WHERE C.created_at = IC.comment_release_time;
