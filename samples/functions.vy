@public
def __init__(_beneficiary: address, _goal: wei_value, _timelimit: timedelta):
		self.beneficiary = _beneficiary
		self.deadline = block.timestamp + _timelimit
		self.timelimit = _timelimit
		self.goal = _goal


# Participate in this crowdfunding campaign
@public
@payable
def participate():
		assert block.timestamp < self.deadline

		nfi: int128 = self.nextFunderIndex

		self.funders[nfi] = {sender: msg.sender, value: msg.value}
		self.nextFunderIndex = nfi + 1