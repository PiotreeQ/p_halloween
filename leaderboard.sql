CREATE TABLE `halloween_leaderboard` (
  `id` int(11) NOT NULL,
  `identifier` varchar(46) NOT NULL,
  `pumpkins` int(11) NOT NULL DEFAULT 0,
  `name` varchar(50) NOT NULL,
  `avatar` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `halloween_leaderboard`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `halloween_leaderboard`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;