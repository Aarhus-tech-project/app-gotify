-- MySQL dump 10.13  Distrib 5.7.42, for osx10.16 (x86_64)
--
-- Host: 100.116.248.20    Database: gotify
-- ------------------------------------------------------
-- Server version	8.0.43

-- Create database
CREATE DATABASE IF NOT EXISTS gotify
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE gotify;

-- Table: album
CREATE TABLE `album` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `artist` VARCHAR(255) NOT NULL,
  `cover_path` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: music
CREATE TABLE `music` (
  `hash` VARCHAR(255) NOT NULL,
  `extension` VARCHAR(100) NOT NULL,
  `song` VARCHAR(255) NOT NULL,
  `track_number` BIGINT DEFAULT NULL,
  `album_id` BIGINT DEFAULT NULL,
  PRIMARY KEY (`hash`),
  UNIQUE KEY `music_unique` (`hash`),
  CONSTRAINT `fk_music_album` FOREIGN KEY (`album_id`) REFERENCES `album`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: user
CREATE TABLE `user` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: playlist
CREATE TABLE `playlist` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_playlist_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: playlist_music
CREATE TABLE `playlist_music` (
  `playlist_id` BIGINT NOT NULL,
  `hash` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`playlist_id`, `hash`),
  CONSTRAINT `fk_playlistmusic_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `playlist`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_playlistmusic_music` FOREIGN KEY (`hash`) REFERENCES `music`(`hash`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Table: playlist_user (many-to-many shared playlist system)
CREATE TABLE `playlist_user` (
  `playlist_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  PRIMARY KEY (`playlist_id`, `user_id`),
  CONSTRAINT `fk_playlistuser_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `playlist`(`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_playlistuser_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE gotify.liked_songs (
    user_id BIGINT NOT NULL,
    song_hash VARCHAR(255) NOT NULL,
    UNIQUE KEY unique_user_song (user_id, song_hash),
    INDEX idx_user_id (user_id),
    INDEX idx_song_hash (song_hash)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;
