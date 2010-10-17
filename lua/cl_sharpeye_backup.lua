////////////////////////////////////////////////
// -- SharpeYe                                //
// by Hurricaaane (Ha3)                       //
//                                            //
// http://www.youtube.com/user/Hurricaaane    //
//--------------------------------------------//
// Backup manager                             //
////////////////////////////////////////////////
local sharpeye = sharpeye

function sharpeye:CheckBackupInit()
	self.dat.RecentBackupDump = self:BackupReadDump()
	self.dat.InitBackupDiffers = self:BackupCompare( self.dat.RecentBackupDump )
	self.dat.LastSaveDiff = 0
	
	self:TryBackupNow()
	
end

function sharpeye:GetLastSaveDiff()
	return self.dat.LastSaveDiff
	
end

function sharpeye:GetRecentBackupDump()
	return self.dat.RecentBackupDump
end

function sharpeye:IsBackupInitDifferent()
	return (self.dat.InitBackupDiffers or 1) > 0
	
end

function sharpeye:BackupInitDifferences()
	return self.dat.InitBackupDiffers or 1
	
end

function sharpeye:TryBackupNow()
	if self:IsBackupInitDifferent() then return false end
	local compare = self:BackupCompare( self:GetRecentBackupDump(), true )
	
	if compare > 0 then
		self.dat.RecentBackupDump = self:BackupGetCurrent()
		self:BackupWriteDump( self:BackupGetCurrent() )
	
	end
	
	self.dat.LastSaveDiff = compare
	
	return true
	
end

function sharpeye:BackupInitDifferentResolve( bRestoreDump )
	if not self:IsBackupInitDifferent() then return end
	
	if bRestoreDump then
		self:BackupSet( self.dat.RecentBackupDump )
		self.dat.RecentBackupDump = self:BackupGetCurrent()
		
	end
	
	self.dat.InitBackupDiffers = 0
	self:TryBackupNow()
	
end

function sharpeye:TryExitBackup()
	if not self:IsBackupInitDifferent() then
		self:BackupWriteCurrent()
		
	end
	
end
