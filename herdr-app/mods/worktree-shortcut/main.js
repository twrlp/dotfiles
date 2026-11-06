import { View, div } from "gpui-kit";
import { focused, spaces, props, closeOverlay, openOverlay, notify } from "herdr";

// A transient key-binding adapter; creation stays in Herdr's shipped dialog.
export default class WorktreeShortcut extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      const space = focused()?.space;
      const exists = spaces().some((item) => item.id === space);
      closeOverlay(props().overlay);
      if (!exists) {
        notify({ title: "New worktree", body: "Select a repository space first.", level: "info" });
        return;
      }
      openOverlay({
        mod: "worktree",
        kind: "dialog",
        width: 440,
        height: 260,
        props: { space, action: "new" },
      });
    });
  }

  render() {
    return div();
  }
}
