**Updated to Ashita v4 by Zal Das and GetAwayCoxn**

This is a simple counter addon.  When you begin to /heal, it counts down from 20 to 0, and when a healing tick is detected, it resets to 10 and starts counting down to 0 again. The healing tick may occur 1-2 seconds before or after the counter hits 0 as server flush and packet travel time can't be known with 100% precision client-side, so this should be treated as an approximation counter and not an absolute source of truth.
