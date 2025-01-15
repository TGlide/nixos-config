import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable } from "astal"
import Battery from "gi://AstalBattery"

const time = Variable("").poll(1000, "date")
const battery = Battery.get_default()

export default function Bar(gdkmonitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	return <window
		className="Bar"
		gdkmonitor={gdkmonitor}
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		anchor={TOP | LEFT | RIGHT}
		application={App}>
		<centerbox>
			<button
				onClicked="echo hello"
				halign={Gtk.Align.CENTER}
			>
				Welcome to AGS!
			</button>
			<box />
			<button
				onClicked={() => print("hello")}
				halign={Gtk.Align.CENTER}
			>
				{battery.percentage.toString()}
			</button>
		</centerbox>
	</window>
}
