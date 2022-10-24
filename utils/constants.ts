// Governor Values
export const QUORUM_PERCENTAGE = 4 // Need 4% of voters to pass
export const MIN_DELAY = 60*60*24*4 // 4 days - after a vote passes, you have 1 hour before you can enact
export const VOTING_PERIOD = 50400 // 1 week - how long the vote lasts. This is pretty long even for local tests
export const VOTING_DELAY = 1 // 1 Block - How many blocks till a proposal vote becomes active
export const ADDRESS_ZERO = "0x0000000000000000000000000000000000000000"

export const PROPOSAL_DESCRIPTION = "Proposal #1"