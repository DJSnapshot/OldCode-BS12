#define NORTH 1
#define SOUTH 2
#define EAST 4
#define WEST 8
#define UP 16
#define DOWN 32
#define ALLDIR NORTH|SOUTH|EAST|WEST|UP|DOWN

#define ABOVE 1
#define BELOW 0


//object properties
#define STRUCTURE_BACKBONE 1	// This object cannot be anchored to anything as it serves as the backbone of the vessel.
#define NOBLUDGEON 2		// Surpresses the default combat message, used by grabs
#define SHARP 4				// This object has an edge
#define FINGERPRINT 8		// Takes a fingerprint
#define NOBLOODY 16			// Does not take blood
#define CONDUCTIVE 32		// Conducts electricity (metal etc.)
#define FLAMABLE 64		// Can burn
#define ACID_PROOF 128		// Replaces Unacidable
#define SLIPPERY 256		// Can slip people.
#define OPENCONTAINER 512	// An open container for chemistry purposes
#define	NOREACT 1024 		// Reagents don't react inside this container.
#define SENSE_PROXIMITY 2048// Streamlines proximity sensing
#define SENSE_ENTRY 4096	// Streamlines entry detection

#define SPECIAL_DENSITY 32736	// Used for stuff that does more complex movement checks.

#define STANDARD_PROPERTIES FINGERPRINT
#define CLOTH_PROPERTIES FLAMABLE
#define METAL_PROPERTIES FINGERPRINT|CONDUCTIVE


//status flags
#define OFF 1			// Obvious
#define BROKEN 2		// ERROR ERROR
#define NOPOWER 4		// No power, duh
#define MAINT 8			// under maintaince
#define EMPED 16		// temporary broken by EMP pulse
#define BURNT 32		// Has been burnt
#define CONTAMINATED 64	// Plasma
#define CRIT_FAIL 128	// Used by science.
#define ARMED 256
#define SECURED 512
#define HIDDEN 1024
//turf-only flags
#define ADJACENT_ABOVE 1	// There is a turf above a turf next to me.
#define ADJACENT_BELOW 2	// There is a turf below a turf next to me.
#define HAS_ABOVE 4			// There is a turf above me.
#define HAS_BELOW 8			// There is a turf below me.

//mob-life
#define MOB_ALIVE 1
#define MOB_CONSCIOUS 2
#define MOB_BLIND 4
#define MOB_DEAF 8

//flags for pass_flags
#define PASSTABLE	1
#define PASSGLASS	2
#define PASSGRILLE	4
#define PASSMOB		8
#define INCORPOREAL 16	// Not effected by jackshit.  Or gravity.


//Layer defines
#define LEVEL_UNDERFLOOR 1
#define LEVEL_FLOOR 2
#define LEVEL_WALL 3