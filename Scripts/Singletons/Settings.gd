extends Node

var botPlay = false # plays the players side automatically
var ghostTapping = false # allows the player to press keys without the miss penalty
var hitSounds = true # play a sound when the player hits a note

var hudRatings = true # display ratings on the hud layer
var hudRatingsOffset = Vector2(640, 360) # if its a hud rating, move it by this offset

var middleScroll = false
var middleScrollPreview = false
var downScroll = false
