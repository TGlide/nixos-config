import { App } from "astal/gtk3"
import style from "./styles/main.scss"
import Bar from "./widget/Bar"
import NotificationPopups from "./notifications/NotificationsPopup"

App.start({
	css: style,
	main() {
		App.get_monitors().map(Bar)
		App.get_monitors().map(NotificationPopups)
	},
})
