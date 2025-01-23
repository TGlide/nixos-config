import { Variable, GLib, bind } from "astal"
import { Astal, Gtk, Gdk } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"
import Mpris from "gi://AstalMpris"
import Wp from "gi://AstalWp"
import Tray from "gi://AstalTray"
import NotificationPopups from "../notifications/NotificationsPopup"

function SysTray() {
	const tray = Tray.get_default()

	return <box className="SysTray">
		{bind(tray, "items").as(items => items.map(item => (
			<menubutton
				tooltipMarkup={bind(item, "tooltipMarkup")}
				usePopover={false}
				// actionGroup={bind(item, "actionGroup").as(ag => ["dbusmenu", ag])}
				menuModel={bind(item, "menuModel")}>
				<icon gicon={bind(item, "gicon")} />
			</menubutton>
		)))}
	</box>
}

function AudioSlider() {
	const speaker = Wp.get_default()?.audio.defaultSpeaker!

	return <box className="AudioSlider" css="min-width: 160px">
		<icon icon={bind(speaker, "volumeIcon")} />
		<slider
			hexpand
			onDragged={({ value }) => speaker.volume = value}
			value={bind(speaker, "volume")}
		/>
		<label>{bind(speaker, "volume").as(v => `${Math.floor(v * 100)}%`)}</label>
	</box>
}

function Media() {
	const mpris = Mpris.get_default()

	return <box
		className="Media"
	>
		{bind(mpris, "players").as(ps => ps[0] ? (
			<box>
				<box
					className="Cover"
					valign={Gtk.Align.CENTER}
					css={bind(ps[0], "coverArt").as(cover =>
						`background-image: url('${cover}');`
					)}
				/>
				<label>
					{bind(ps[0], "title")}
				</label>
				<label> - </label>
				<label>
					{bind(ps[0], "artist")}
				</label>
			</box>
		) : (
			"Nothing Playing"
		))}
	</box>
}

function Workspaces() {
	const hypr = Hyprland.get_default()

	return <box className="Workspaces">
		{bind(hypr, "workspaces").as(wss => wss
			.filter(ws => !(ws.id >= -99 && ws.id <= -2)) // filter out special workspaces
			.sort((a, b) => a.id - b.id)
			.map(ws => (
				<button
					className={bind(hypr, "focusedWorkspace").as(fw =>
						ws === fw ? "focused" : "")}
					onClicked={() => ws.focus()}>
					{ws.id}
				</button>
			))
		)}
	</box>
}

function FocusedClient() {
	const hypr = Hyprland.get_default()
	const focused = bind(hypr, "focusedClient")

	return <box
		className="FocusedClient"
		visible={focused.as(Boolean)}>
		{focused.as(client => (
			client && <label label={bind(client, "title").as(String)} />
		))}
	</box>
}

function Time({ format = "%H:%M - %e/%m/%Y" }) {
	const time = Variable<string>("").poll(1000, () =>
		GLib.DateTime.new_now_local().format(format)!)

	return <label
		className="Time"
		onDestroy={() => time.drop()}
	>
		{time()}
	</label>
}

export default function Bar(monitor: Gdk.Monitor) {
	const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

	return <window
		className="Bar"
		gdkmonitor={monitor}
		exclusivity={Astal.Exclusivity.EXCLUSIVE}
		anchor={TOP | LEFT | RIGHT}>
		<centerbox>
			<box hexpand halign={Gtk.Align.START}>
				<Workspaces />
				<FocusedClient />
			</box>
			<box>
				<Media />
			</box>
			<box hexpand halign={Gtk.Align.END} >
				<SysTray />
				<AudioSlider />
				<Time />
			</box>
		</centerbox>
	</window>
}
