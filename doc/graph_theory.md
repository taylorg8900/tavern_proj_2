# 0 - Overview
I need to use graph theory to generate levels, because the layout of the levels needs to have loop composites and tree composites. I really want there to be loop composites so that the player can feel like 
they have many different ways of navigating through the level, and if I only had tree composites then the player would never get lost in the level. I also want to avoid backtracking, as if the tree composites of the 
level were very deep, then once the player got to the end, they would have to backtrack all the way to the beginning which would kind of be a waste of time.

Basically, I want the level generation to function similar to how Enter the Gungeon generates it's levels. Each level is defined by an overall graph structure, and during generation, an algorithm goes and divides the 
graph structure into separate tree and loop composites. Then, it will generate layouts using pre fabricated rooms that match that composite, and finally stitch all of the composites together to create the level.

The reason I need graph theory specifically is for dividing the graph structure of a level into loop and tree composites. Generating the level layout and stitching the composites together comes after that.

I haven't studied graph theory yet, so this document is for me to understand in a more general way how graphs are represented, how you can search through them algorithmically, and how to represent algorithms in
pseudocode. After getting a good understanding of that, I can create my own algorithm to divide a graph structure into loop and tree composites.

# 1 - Requirements Analysis
Here is a list of things I need to understand:
- graph representation
	- 
- graph traversal algorithms
- shortest path algorithms
- minimum spanning tree algorithms
- cycle detection

# 2 - Design

# 3 - Implementation

# 4 - Testing and Debugging

# 5 - Deployment

# 6 - Maintenance