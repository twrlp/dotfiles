import { View, div, svg } from "gpui-kit";
import { h_flex, v_flex, HoverCard } from "gpui-base";
import { appHome, exec, shared, setShared, theme } from "herdr";
import { view } from "./model.js";

const KEY = "usage-bar.providers";
const epoch = () => Math.floor(Date.now() / 1000);
const initial = () => [{ id: "codex", name: "Codex", status: "loading" }];

export default class UsageBar extends View {
  init(_props, cx) {
    this.busy = false;
    this.lastAttempt = 0;
    this.refresh(cx);
    cx.timer.every(60000, (cx) => {
      if (epoch() - this.lastAttempt >= 300) this.refresh(cx);
      cx.notify();
    });
  }

  refresh(cx) {
    if (this.busy) return;
    this.busy = true;
    this.lastAttempt = epoch();
    cx.notify();
    cx.spawn(async (cx) => {
      const previous = shared(KEY) ?? initial();
      try {
        const result = await exec("python3", [`${appHome()}/mods/agent-usage/read_usage.py`]);
        const output = JSON.parse(result.stdout);
        if (!Array.isArray(output.providers) || !output.providers.length) throw new Error("No provider results");
        const providers = output.providers.map((provider) => {
          const old = previous.find((item) => item.id === provider.id);
          const lastGood = provider.status === "ok" ? provider
            : provider.status === "error" ? old?.lastGood ?? null : null;
          return { ...provider, lastGood };
        });
        setShared(KEY, providers);
      } catch {
        setShared(KEY, previous.map((provider) => ({ ...provider, status: "error", error: "Usage reader unavailable; check Python and Codex installation" })));
      } finally {
        this.busy = false;
        cx.notify();
      }
    });
  }

  provider(provider, t) {
    const data = view(provider.lastGood, provider.error, epoch(), provider.id, provider.status);
    const color = (level) => level === "hot" ? t.ansi1 : level === "warn" ? t.ansi3 : level === "dim" ? t.muted : t.foreground;
    const name = provider.name ?? provider.id;
    const title = provider.id === "codex" ? "ChatGPT · Codex" : name;
    const icon = () => provider.id === "codex"
      ? svg("mods/agent-usage/chatgpt.svg").size(14).text_color(t.foreground)
      : div().font_semibold().child(name);
    const trigger = h_flex().id(`usage-${provider.id}`).h(24).px(7).gap(8).items_center()
      .rounded(5).cursor_pointer().hover((s) => s.bg(t.hover))
      .accessibility_label(`${title}: ${data.detail || data.status}. Click to refresh.`)
      .on_click((_event, cx) => this.refresh(cx)).child(icon())
      .when(!data.rows.length, (el) => el.child(div().text_color(t.muted).child(data.status)))
      .children(data.rows.map((row) =>
        h_flex().gap(4).items_center()
          .child(div().text_color(t.muted).child(row.compactLabel))
          .child(div().text_color(color(row.level)).font_semibold().child(row.remaining))))
      .when(Boolean(data.rows.length && data.status), (el) => el.child(div().text_color(t.muted).child(data.status)))
      .opacity(this.busy ? 0.6 : 1);
    const card = v_flex().w(300).p(16).gap(14).bg(t.popover).text_color(t.foreground)
      .text_size(13).border(1).border_color(t.border).rounded(10).shadow_md()
      .child(h_flex().gap(8).items_center().child(icon()).child(div().font_semibold().child(title)))
      .when(Boolean(data.status), (el) => el.child(div().text_color(t.muted).child(data.detail.split("\n")[0] || data.status)))
      .children(data.rows.map((row) => v_flex().gap(5)
        .child(h_flex().justify_between().gap(16)
          .child(div().child(row.label === "5h" ? "5-hour limit" : row.label === "week" ? "Weekly limit" : row.label))
          .child(div().font_semibold().text_color(color(row.level)).child(`${row.remaining} left`)))
        .child(div().text_color(t.muted).text_size(12).child(row.resetAt
          ? `Resets ${row.resetAt} · ${row.reset}` : "Reset time unavailable"))))
      .when(Boolean(provider.lastGood), (el) => el.child(div().text_size(11.5).text_color(t.muted)
        .child(`Updated ${new Date(provider.lastGood.observedAt * 1000).toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })}`)));
    return HoverCard.new(`usage-details-${provider.id}`).anchor("bottom_right")
      .open_delay(350).close_delay(150).trigger(trigger).content(card);
  }

  render() {
    const t = theme();
    const providers = shared(KEY) ?? initial();
    return h_flex().id("usage-bar").size_full().px(7).gap(10).items_center().justify_end()
      .bg(t.chrome).border_t(1).border_color(t.border).text_size(11.8).text_color(t.muted)
      .children(providers.map((provider) => this.provider(provider, t)));
  }
}
