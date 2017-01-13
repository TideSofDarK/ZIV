var currentMusic = 0;

(function () {
	Game.StopMusic = (function () {
		Game.StopSound(currentMusic)
	});
	Game.PlayMusic = (function (soundEvent) {
		// Game.StopMusic();
		currentMusic = Game.EmitSound(soundEvent)
	});
})();