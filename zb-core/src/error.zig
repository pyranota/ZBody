pub const TreeError = error{ //
// Tree has not been finalized before traversing
NotFinalized,
// You are trying to place
BodyAtGivenPositionAlreadyExist,
// Dont try to spawn bodies outside of given tree size
PositionOutOfBound,
// You pray to GOD you never see this.
Unexpected };
