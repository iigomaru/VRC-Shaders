# VRC-Shaders
Various Shaders for Vrchat written mostly originally for my friend's projects.

## 2D Hologram
The 2D hologram shader is a simple unlit shader that creates a hologram effect with a slick distance based fade effect written originally for [Ostinyo](https://vrchat.com/home/user/usr_b231cc91-30ea-4181-8ae6-d7dd85794120).

## Player Only Mirrors
A new way of masking out the background using the novel method of using negative hdr values that eliminates the nasty black outline commonplace with most player only mirrors, to use place the mirror shader on a vrchat mirror with the layers Player and MirrorReflection, and then place the transparent background shader on a mesh around the area that you want to have players reflect, this background shader is visable in regular mirrors so keep this in mind. This shader also as a distance fade effect that is configurable in the properties, and is confirmed to be quest compatible.
