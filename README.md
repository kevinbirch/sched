# sched

This is a super nifty utility program that allows you to quickly add reminders and events to iCal.  When combined with a launcher
program such as [Alfred](http://www.alfredapp.com/), it's easy to dash off a new calendar item.

You can download the latest version [here](https://github.com/kevinbirch/sched/downloads).

## Creating Reminders

When you run the app, it looks like this:

![initial window](https://raw.github.com/kevinbirch/sched/master/images/sched-reminder.png)

To create a new reminder, simply enter the description, hit the return key and you're done!

Reminder items require at least a description, all of the other settings are optional or defaulted.  If you want to 
set a due date, tab to the second field and enter a date and time string such as:

- today at 5pm
- friday at 9am
- september 10, 2199 at 10:15am

Several variations of date formats are supported, so try naturally formatted date/time values and it probably will work.

By default new reminders are created in your "Home" calendar (if one exists). If a due date is specified then an alarm
(dialog with sound alert) at that time is added to the reminder.  You can change this behavior using the preferences
(see the preferences section below).

The application window opens in a collapsed state initially, but additional options can be set on the reminder if
needed.  Simply press ⌘B (Item Menu -> More Options) or click on the disclosure triangle next to the text "More
Options".  The window will now look like this:

![more reminder options](https://raw.github.com/kevinbirch/sched/master/images/sched-reminder-full.png)

Using these additional controls, you can set all of the other options for a reminder.  The only difference from iCal is
that the send email, open file and run script alarm types are not supported.

N.B. While it is possible give a reminder a due date AND mark it as completed, this probably doesn't make much sense.

## Creating Events

To create a event, press ⌘E (Item Menu -> Event) or click on the Event tab.  You can now fill in the description and
the start date/time (both are required).  Like the reminder due date field, the start date field supports flexible
input language, so try what seems natural (see some examples above).

![event form](https://raw.github.com/kevinbirch/sched/master/images/sched-event.png)

To set additional options press ⌘B (Item Menu -> More Options) or click on the disclosure triangle next to the text
"More Options".  If you've already expanded the more options area it will remain open as you switch between tabs until
you hide it again.  The window will now look like this:

![event form](https://raw.github.com/kevinbirch/sched/master/images/sched-event-full.png)

The end date/time for the event will be calculated from the start date plus the value of the duration.  The field
accepts decimal values, so .25 is 15 minutes and 1.5 is an hour and a half (the default is 1.0 - one hour).  By default,
an alarm is created 15 minutes before the start time of the event, except for all day events which have a default alarm
of 9:00AM of the start day.  The various default values for these options can all be configured in the preferences.

Please note the following:

- You can configure most of the options of an event using these controls but location, repetition, free/busy and
invitees are not supported.
- Marking an event as all day automatically changes the units of the event duration from "hours" to "days".
- All day events will still show a time component in the start date/time field, but it will be ignored.

## Colophon

In ancient times, I wrote this same application using XCode's support for pure AppleScript applications.  Eventually it
stopped working, as the calendar substrate changed over time.  However, I've saved the original code for posterity as a
[gist](https://gist.github.com/3539923).  This will only be interesting to hardcore Apple nerds and software crypto-archaeologists.

## License

Copyright (c) 2012 [Kevin Birch](kmb@pobox.com)

Distributed under an [MIT-style](http://www.opensource.org/licenses/mit-license.php) license.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
