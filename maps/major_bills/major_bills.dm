#if !defined(USING_MAP_DATUM)

	#include "major_bills-1.dmm"

	#include "major_bills_defines.dm"
	#include "major_bills_areas.dm"
	#include "major_bills_job.dm"


	#define USING_MAP_DATUM /datum/map/major_bills

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring MAJOR BILLS

#endif