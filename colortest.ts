#!/home/azbyn/Projects/d_throwaway/throwaway_script
ansi_names = [
    "Black", "Red", "Green", "Yellow",
    "Blue", "Magenta", "Cyan", "White",
    "Bright_Black", "Bright_Red", "Bright_Green", "Bright_Yellow",
    "Bright_Blue", "Bright_Magenta", "Bright_Cyan", "Bright_White"
    ];
ansi_to_base16 = [
    0x0, 0x8, 0xB, 0xA,
    0xD, 0xE, 0xC, 0x5,
    0x3, 0x8, 0xB, 0xA,
    0xD, 0xE, 0xC, 0x7,
    0x9, 0xF, 0x1, 0x2,
    0x4, 0x6
];

colors = [
    "1D1F21", "282A2E", "373B41", "969896",
    "B4B7B4", "E0E0E0", "F0F0F0", "FFFFFF",
    "CC342B", "F96A38", "FBA922", "198844",
    "12A59C", "3971ED", "A36AC7", "FBA922"
];
base16_to_ansi = [
     0, 18, 19,  8,
    20,  7, 21, 15,
     1, 16,  3,  2,
     6,  4,  5, 17,
];
fun fullOrShort(max) {
    for (i in range(0, max)) {
        for (j in range(30, 38)) {
            for (k in range(40, 48)) {
                printf("#033[@;@;@m##@;@;@#033[m", i, j, k, i, j, k);
            }
            println();
        }
        println();
    }
}

fullOrShort(1);

#my $a = defined $ARGV[0] ? $ARGV[0] : "";
#if ($a eq "full" || $a eq "f") {
#	full_or_short(9)
#}
#elsif ($a eq "short" || $a eq "s") {
#	full_or_short(1)
#}
#elsif ($a eq "ordered" || $a eq "o") {
#	for my $i (0..15) {
#		my $ansi = $base16_to_ansi[$i];
#		printf "\33[38;5;%dmbase%02X  %-15s %s \\33[38;5;%dm \33[0m\n",
#			$ansi, $i, $colors[$i], "█" x 25, $ansi;
#	}
#}
#else {
#	for my $i (0..21) {
#		my $name  = $i < 0+@ansi_names ? $ansi_names[$i] : "";
#		my $base16 = $ansi_to_base16[$i];
#		printf "\33[38;5;%dmcolor%02d base%02X %s %-15s %s \33[0m\n",
#			$i, $i, $base16, $colors[$base16], $name, "█" x 25;
#	}
#}
#
