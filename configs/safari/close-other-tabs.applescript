on run
	if my safariIsFrontmost() is false then return

	set activeTabInfo to my activeSafariTabInfo()
	set activeHost to item 1 of activeTabInfo
	if activeHost is "" then return

	set activeTabIndex to item 2 of activeTabInfo
	my closeOtherTabsForHost(activeHost, activeTabIndex)
end run

on safariIsFrontmost()
	if not (application "Safari" is running) then return false
	tell application "Safari" to return frontmost
end safariIsFrontmost

on activeSafariTabInfo()
	tell application "Safari"
		if (count of windows) = 0 then return {"", 0}

		set currentTabRef to current tab of front window
		set currentURL to URL of currentTabRef
		set currentHost to my hostForURL(currentURL)
		set currentTabIndex to index of currentTabRef
		return {currentHost, currentTabIndex}
	end tell
end activeSafariTabInfo

on closeOtherTabsForHost(activeHost, activeTabIndex)
	tell application "Safari"
		repeat with windowIndex from (count of windows) to 1 by -1
			set targetWindow to window windowIndex
			my closeMatchingTabsInWindow(targetWindow, windowIndex, activeTabIndex, activeHost)
		end repeat
	end tell
end closeOtherTabsForHost

on closeMatchingTabsInWindow(targetWindow, windowIndex, activeTabIndex, activeHost)
	tell application "Safari"
		repeat with tabIndex from (count of tabs of targetWindow) to 1 by -1
			if not (windowIndex = 1 and tabIndex = activeTabIndex) then
				set targetTab to tab tabIndex of targetWindow
				set candidateHost to my hostForURL(URL of targetTab)
				if my hostsMatch(candidateHost, activeHost) then close targetTab
			end if
		end repeat
	end tell
end closeMatchingTabsInWindow

on hostsMatch(firstHost, secondHost)
	if firstHost is "" or secondHost is "" then return false
	ignoring case
		return firstHost is secondHost
	end ignoring
end hostsMatch

on hostForURL(pageURL)
	if pageURL is missing value then return ""
	set pageURL to pageURL as text

	set schemeSeparator to offset of "://" in pageURL
	if schemeSeparator = 0 then return ""
	set urlSchemeText to text 1 thru (schemeSeparator - 1) of pageURL
	ignoring case
		if urlSchemeText is not "http" and urlSchemeText is not "https" then return ""
	end ignoring

	set authorityStart to schemeSeparator + 3
	if authorityStart > (count of pageURL) then return ""
	set authorityText to text authorityStart thru -1 of pageURL

	repeat with separatorReference in {"/", "?", "#"}
		set separatorText to contents of separatorReference
		set separatorPosition to offset of separatorText in authorityText
		if separatorPosition = 1 then
			set authorityText to ""
		else if separatorPosition > 1 then
			set authorityText to text 1 thru (separatorPosition - 1) of authorityText
		end if
	end repeat
	if authorityText is "" then return ""

	set savedDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to "@"
	set authorityParts to text items of authorityText
	set authorityText to last item of authorityParts
	set AppleScript's text item delimiters to savedDelimiters

	if authorityText starts with "[" then
		set closingBracket to offset of "]" in authorityText
		if closingBracket > 0 then return text 1 thru closingBracket of authorityText
	end if

	set savedDelimiters to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ":"
	set hostParts to text items of authorityText
	set parsedHost to first item of hostParts
	set AppleScript's text item delimiters to savedDelimiters
	return parsedHost
end hostForURL
