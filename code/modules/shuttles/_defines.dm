#define SHUTTLE_FLAGS_NONE 0
#define SHUTTLE_FLAGS_PROCESS 1
#define SHUTTLE_FLAGS_SUPPLY 2
#define SHUTTLE_FLAGS_ALL (~SHUTTLE_FLAGS_NONE)

#define SHUTTLE_SPEED_SLOW		1		// The speed the autopilot flies at. Also may help avoiding harm in certain encounters.
#define SHUTTLE_SPEED_NORMAL	2		// The baseline speed, the autopilot cannot fly at this speed. Can suffer from attritional damage.
#define SHUTTLE_SPEED_HYPER		3		// A specialized speed that heavily damages the shuttle when used, intended only for emergency use.

#define SHUTTLE_FAULT_NONE		0
#define SHUTTLE_FAULT_MINOR		1	// Minor faults generally reduce the overall performance of the component.
#define SHUTTLE_FAULT_MAJOR		2	// Major faults generally cause the component to fail or otherwise do bad things, and is much more serious.
#define SHUTTLE_FAULT_CRITICAL	3	// Critical faults make the component fail entirely, and cannot be repaired. They must be replaced.

// The default thruster strength, measured in AUD.
// AUD stands for Arbitrary Unit of Distance.
#define SHUTTLE_DEFAULT_THRUSTER_POWER 25

// How many thrusters are on the regular shuttles.
// Used for the below define for standardizing seconds to AUD.
#define SHUTTLE_DEFAULT_THRUSTER_AMOUNT 4

// Converts desired seconds to the amount of AUD needed for it to be true at default speeds.
#define SHUTTLE_SECONDS * (SHUTTLE_DEFAULT_THRUSTER_POWER * SHUTTLE_DEFAULT_THRUSTER_AMOUNT)