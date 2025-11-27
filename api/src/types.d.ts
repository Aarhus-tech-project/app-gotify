type Id = number | string;

interface IPlaylist {
    id: Id;
    name: string;
}

interface IPlaylistWithMusic {
    id: Id;
    name: string;
    music: IMusic[];
}

interface IMusic {
    file: string;
    artist: string;
    album: string;
    song: string;
    trackNumber: Id;
    cover: string;
    liked: boolean;
}

interface IAlbum {
    albumId: Id;
    album: string;
    cover: string;
    artist: string;
    songs: IMusic[];
}

interface IUsers {
    id: Id;
    username: string;
}