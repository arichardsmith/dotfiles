import { stringify } from "jsr:@std/toml";

type AerospaceMode = "main" | "edit" | "service";

export class AerospaceConfigBuilder<WS extends string> {
  readonly cmd = new Cmds<WS>();

  // Default values should be from https://github.com/nikitabobko/AeroSpace/blob/master/default-config.toml
  // just without the key bindings
  private cfg: OutputConfig = {
    "after-login-command": [],
    "after-startup-command": [],
    "start-at-login": false,
    "enable-normalization-flatten-containers": true,
    "enable-normalization-opposite-orientation-for-nested-containers": true,
    "accordion-padding": 30,
    "default-root-container-layout": "tiles",
    "default-root-container-orientation": "auto",
    "key-mapping": {
      preset: "qwerty",
    },
    gaps: {
      inner: {
        horizontal: 4,
        vertical: 4,
      },
      outer: {
        left: 6,
        bottom: 6,
        top: 6,
        right: 6,
      },
    },
    mode: {
      main: {
        binding: {},
      },
      edit: {
        binding: {},
      },
      service: {
        binding: {},
      },
    },
    "workspace-to-monitor-force-assignment": {},
  };

  static with_workspaces<T extends string | number>(workspaces: T[]) {
    const names = workspaces.map((name) => {
      if (typeof name === "number") {
        return `${name}`;
      }

      return name.toUpperCase();
    }) as RewriteWorkspaceName<T>[];

    return new AerospaceConfigBuilder<RewriteWorkspaceName<T>>(names);
  }

  constructor(workspaces: WS[]) {
    this.#set_up_mode_bindings();
    this.#set_up_workspace_bindings(workspaces);
    this.#set_up_directional_bindings();
    this.#set_up_resize_bindings();
    this.#set_up_layout_bindings();
    this.#set_up_float_bindings();
    this.#set_up_service_bindings();
  }

  mouse_follows_focus() {
    this.cfg["on-focused-monitor-changed"] = ["move-mouse monitor-lazy-center"];
    this.cfg["on-focus-changed"] = ["move-mouse window-lazy-center"];
  }

  default_root_layout(layout: "tiles" | "accordion") {
    this.cfg["default-root-container-layout"] = layout;
  }

  gaps({
    inner,
    outer,
    accordion,
  }: {
    inner?: number;
    outer?: number;
    accordion?: number;
  }) {
    if (inner) {
      this.cfg["gaps"]["inner"] = {
        horizontal: inner,
        vertical: inner,
      };
    }

    if (outer) {
      this.cfg["gaps"]["outer"] = {
        left: outer,
        bottom: outer,
        top: outer,
        right: outer,
      };
    }

    if (accordion) {
      this.cfg["accordion-padding"] = accordion;
    }
  }

  assign_to_monitor(workspace: WS, monitor: string) {
    this.cfg["workspace-to-monitor-force-assignment"][workspace] = monitor;
  }

  assign_to_built_in_monitor(workspace: WS) {
    this.cfg["workspace-to-monitor-force-assignment"][workspace] = "built-in";
  }

  add_binding(mode: AerospaceMode, key: string, command: string | string[]) {
    this.cfg.mode[mode].binding[key] = command;
  }

  /** Defines which workspace is mapped to space */
  set_default_workspace(workspace: WS) {
    this.#bind_workspace(workspace, "space");
  }

  /**
   * Output the config as TOML
   */
  render() {
    return stringify(this.cfg);
  }

  #set_up_mode_bindings() {
    this.add_binding("main", "alt-semicolon", this.cmd.switch_mode("service"));
    this.add_binding(
      "main",
      "alt-shift-semicolon",
      this.cmd.switch_mode("service")
    );
    this.add_binding("main", "alt-period", this.cmd.switch_mode("edit"));

    this.add_binding("service", "esc", this.cmd.switch_mode("main"));
    this.add_binding("service", "alt-period", this.cmd.switch_mode("edit"));

    this.add_binding("edit", "esc", this.cmd.switch_mode("main"));
    this.add_binding("edit", "alt-semicolon", this.cmd.switch_mode("service"));
  }

  #set_up_directional_bindings() {
    this.add_binding("main", "alt-h", this.cmd.move_focus("left"));
    this.add_binding("main", "alt-j", this.cmd.move_focus("down"));
    this.add_binding("main", "alt-k", this.cmd.move_focus("up"));
    this.add_binding("main", "alt-l", this.cmd.move_focus("right"));

    this.add_binding("edit", "shift-h", this.cmd.move_focus("left"));
    this.add_binding("edit", "shift-j", this.cmd.move_focus("down"));
    this.add_binding("edit", "shift-k", this.cmd.move_focus("up"));
    this.add_binding("edit", "shift-l", this.cmd.move_focus("right"));

    this.add_binding(
      "edit",
      "h",
      this.cmd.do_and_return_to_main(this.cmd.move_window("left"))
    );
    this.add_binding(
      "edit",
      "j",
      this.cmd.do_and_return_to_main(this.cmd.move_window("down"))
    );
    this.add_binding(
      "edit",
      "k",
      this.cmd.do_and_return_to_main(this.cmd.move_window("up"))
    );
    this.add_binding(
      "edit",
      "l",
      this.cmd.do_and_return_to_main(this.cmd.move_window("right"))
    );

    this.add_binding("edit", "alt-h", this.cmd.join_window("left"));
    this.add_binding("edit", "alt-j", this.cmd.join_window("down"));
    this.add_binding("edit", "alt-k", this.cmd.join_window("up"));
    this.add_binding("edit", "alt-l", this.cmd.join_window("right"));
  }

  #set_up_float_bindings() {
    this.add_binding("main", "alt-f", this.cmd.toggle_floating());
    this.add_binding(
      "edit",
      "f",
      this.cmd.do_and_return_to_main(this.cmd.toggle_floating())
    );
    this.add_binding("edit", "alt-f", this.cmd.toggle_floating());
  }

  #set_up_service_bindings() {
    this.add_binding(
      "service",
      "r",
      this.cmd.do_and_return_to_main(this.cmd.reload_config())
    );
    this.add_binding("service", "q", this.cmd.disable_aerospace());
  }

  #set_up_resize_bindings() {
    this.add_binding(
      "main",
      "alt-shift-minus",
      this.cmd.resize_window(-50, "smart")
    );
    this.add_binding(
      "main",
      "alt-shift-equal",
      this.cmd.resize_window(50, "smart")
    );

    this.add_binding("edit", "minus", this.cmd.resize_window(-50, "width"));
    this.add_binding("edit", "equal", this.cmd.resize_window(50, "width"));
  }

  #set_up_layout_bindings() {
    this.add_binding(
      "edit",
      "backslash",
      this.cmd.do_and_return_to_main(this.cmd.toggle_layout("tiles"))
    );
    this.add_binding("edit", "alt-backslash", this.cmd.toggle_layout("tiles"));

    this.add_binding(
      "edit",
      "slash",
      this.cmd.do_and_return_to_main(this.cmd.toggle_layout("accordion"))
    );
    this.add_binding("edit", "alt-slash", this.cmd.toggle_layout("accordion"));
  }

  #set_up_workspace_bindings(workspaces: WS[]) {
    this.add_binding("main", "alt-slash", this.cmd.toggle_workspace());

    this.add_binding(
      "edit",
      "rightSquareBracket",
      this.cmd.move_workspace_to_next_monitor()
    );

    for (const ws of workspaces) {
      this.#bind_workspace(ws, ws);
    }
  }

  #bind_workspace(workspace: WS, key: string) {
    key = key.toLowerCase();

    if (["h", "j", "k", "l"].includes(key)) {
      // Skip bindings that will clash with the directional bindings
      return;
    }

    this.add_binding(
      "main",
      `alt-${key}`,
      this.cmd.switch_workspace(workspace)
    );
    this.add_binding(
      "main",
      `alt-shift-${key}`,
      this.cmd.move_and_switch_workspace(workspace)
    );

    this.add_binding("edit", `${key}`, this.cmd.move_to_workspace(workspace));
  }
}

type OutputConfig = {
  "after-login-command": string[];
  "after-startup-command": string[];
  "start-at-login": boolean;
  "enable-normalization-flatten-containers": boolean;
  "enable-normalization-opposite-orientation-for-nested-containers": boolean;
  "accordion-padding": number;
  "default-root-container-layout": "tiles" | "accordion";
  "default-root-container-orientation": string;
  "key-mapping": {
    preset: string;
  };
  "on-focused-monitor-changed"?: string[];
  "on-focus-changed"?: string[];
  gaps: {
    inner: {
      horizontal: number;
      vertical: number;
    };
    outer: {
      left: number;
      bottom: number;
      top: number;
      right: number;
    };
  };
  mode: {
    main: ConfigMode;
    [mode: string]: ConfigMode;
  };
  "workspace-to-monitor-force-assignment": {
    [workspace: string]: string;
  };
};

type ConfigMode = {
  binding: {
    [key: string]: string | string[];
  };
};

/**
 * Helpers for typing aerospace commands
 *
 * This is non-exhaustive, for all commands see https://nikitabobko.github.io/AeroSpace/commands
 */
class Cmds<WS extends string> {
  toggle_layout(mode: "tiles" | "accordion") {
    return `layout ${mode} horizontal vertical`;
  }

  move_focus(direction: MovementDirection) {
    return `focus ${direction}`;
  }

  move_window(direction: MovementDirection) {
    return `move ${direction}`;
  }

  resize_window(amount: number, type: "smart" | "width" | "height" = "smart") {
    const sign = amount > 0 ? "+" : "-";
    return `resize ${type} ${sign}${Math.abs(amount)}`;
  }

  switch_workspace(name: WS) {
    return `workspace ${name}`;
  }

  move_to_workspace(name: WS) {
    return `move-node-to-workspace ${name}`;
  }

  move_and_switch_workspace(name: WS) {
    return [`move-node-to-workspace ${name}`, `workspace ${name}`];
  }

  toggle_floating() {
    return `layout floating tiling`;
  }

  toggle_workspace() {
    return `workspace-back-and-forth`;
  }

  move_workspace_to_next_monitor() {
    return `move-workspace-to-monitor --wrap-around next`;
  }

  switch_mode(mode: AerospaceMode) {
    return `mode ${mode}`;
  }

  switch_to_main_mode() {
    return `mode main`;
  }

  disable_aerospace() {
    return `enable off`;
  }

  reload_config() {
    return `reload-config`;
  }

  do_and_return_to_main(command: string) {
    return [command, `mode main`];
  }

  join_window(direction: MovementDirection) {
    return `join-with ${direction}`;
  }
}

type MovementDirection = "left" | "down" | "up" | "right";

type RewriteWorkspaceName<T extends string | number> = T extends string
  ? Uppercase<T>
  : `${T}`;
