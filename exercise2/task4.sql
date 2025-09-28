-- engagement: comments & reactions
CREATE TEMPORARY VIEW user_pairs AS
SELECT DISTINCT (CASE WHEN U1.id > U2.id THEN U1.id ELSE U2.id END) user1_id,
                (CASE WHEN U1.id > U2.id THEN U2.id ELSE U1.id END) user2_id
FROM users U1
         INNER JOIN users U2
WHERE U1.id != U2.id;


-- Actual query
SELECT user1_id, user2_id, (SUM(bidir_engagement.engagement)) total_engagement
FROM (SELECT user1_id, user2_id, (COUNT(DISTINCT C1.id) + COUNT(DISTINCT R1.id)) engagement
      FROM user_pairs
               LEFT JOIN posts P1 ON user1_id = P1.user_id
               LEFT JOIN comments C1 ON P1.id = C1.post_id AND user2_id = C1.user_id
               LEFT JOIN reactions R1 ON P1.id = R1.post_id AND user2_id = R1.user_id
      GROUP BY user1_id, user2_id
      UNION ALL
      SELECT user1_id, user2_id, (COUNT(DISTINCT C2.id) + COUNT(DISTINCT R2.id)) engagement
      FROM user_pairs
               LEFT JOIN posts P2 ON user2_id = P2.user_id
               LEFT JOIN comments C2 ON P2.id = C2.post_id AND user1_id = C2.user_id
               LEFT JOIN reactions R2 ON P2.id = R2.post_id AND user1_id = R2.user_id
      GROUP BY user1_id, user2_id) bidir_engagement
GROUP BY user1_id, user2_id
ORDER BY total_engagement DESC
LIMIT 3;



--
-- Testing related queries
--

SELECT COUNT(DISTINCT comments.id)
FROM users
         INNER JOIN posts ON users.id = posts.user_id
         INNER JOIN comments ON posts.id = comments.post_id
WHERE users.id = 88
  AND comments.user_id = 38;

SELECT COUNT(DISTINCT comments.id)
FROM users
         INNER JOIN posts ON users.id = posts.user_id
         INNER JOIN comments ON posts.id = comments.post_id
WHERE users.id = 38
  AND comments.user_id = 88;

SELECT COUNT(DISTINCT reactions.id)
FROM users
         INNER JOIN posts ON users.id = posts.user_id
         INNER JOIN reactions ON posts.id = reactions.post_id
WHERE users.id = 88
  AND reactions.user_id = 38;

SELECT COUNT(DISTINCT reactions.id)
FROM users
         INNER JOIN posts ON users.id = posts.user_id
         INNER JOIN reactions ON posts.id = reactions.post_id
WHERE users.id = 38
  AND reactions.user_id = 88;


-- MORE TESTING

SELECT user1_id, user2_id, (COUNT(DISTINCT C1.id) + COUNT(DISTINCT R1.id)) engagement
FROM user_pairs
         INNER JOIN posts P1 ON user1_id = P1.user_id
         LEFT JOIN comments C1 ON P1.id = C1.post_id AND user2_id = C1.user_id
         LEFT JOIN reactions R1 ON P1.id = R1.post_id AND user2_id = R1.user_id
WHERE user1_id = 88
  AND user2_id = 38
GROUP BY user1_id, user2_id;

SELECT user1_id, user2_id, (COUNT(DISTINCT C2.id) + COUNT(DISTINCT R2.id)) engagement
FROM user_pairs
         INNER JOIN posts P2 ON user2_id = P2.user_id
         LEFT JOIN comments C2 ON P2.id = C2.post_id AND user1_id = C2.user_id
         LEFT JOIN reactions R2 ON P2.id = R2.post_id AND user1_id = R2.user_id
WHERE user1_id = 88
  AND user2_id = 38
GROUP BY user1_id, user2_id;
