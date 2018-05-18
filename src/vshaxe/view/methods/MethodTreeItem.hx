package vshaxe.view.methods;

import vshaxe.server.Response;

class MethodTreeItem extends TreeItem {
    final context:ExtensionContext;
    final timer:Timer;
    final name:String;

    var isRoot(get,never):Bool;
    inline function get_isRoot() return parent == null;

    public final children:Null<Array<MethodTreeItem>>;
    public final method:String;
    public final parent:Null<MethodTreeItem>;

    public function new(context:ExtensionContext, parent:MethodTreeItem, timer:Timer, method:String) {
        super("");
        this.context = context;
        this.parent = parent;
        this.timer = timer;
        this.method = method;

        name = formatName();
        label = formatLabel();
        tooltip = formatTooltip();
        id = '$method $name ${timer.info}';
        if (timer.children == null) {
            children = null;
            collapsibleState = None;
        } else {
            children = timer.children.map(MethodTreeItem.new.bind(context, this, _, method));
            collapsibleState = Expanded;
        }
        if (isRoot) {
            iconPath = {
                light: context.asAbsolutePath("resources/light/method.svg"),
                dark: context.asAbsolutePath("resources/dark/method.svg")
            };
        }
    }

    function formatName():String {
        var name = if (isRoot) method else timer.name;
        if (timer.info != "") {
            name = '${timer.info}.$name';
        }
        return name;
    }

    function formatLabel():String {
        var seconds = truncate(timer.time, 5);
        var percent = truncate(timer.percentTotal, 4);
        var label = '$name - ${seconds}s';
        if (!isRoot) {
            label += ' ($percent%)';
        }
        return label;
    }

    function formatTooltip():String {
        var now = Date.now();
        var timestamp = '[${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}]';
        return '$timestamp ${timer.calls} calls - ${truncate(timer.time, 7)}s';
    }

    function truncate(f:Float, precision:Int) {
        return Std.string(f).substr(0, precision);
    }

    public function toString(indent:String = ""):String {
        var result = indent + label;
        if (children != null) {
            result += "\n" + children.map(child -> child.toString(indent + "  ")).join("\n");
        }
        return result;
    }
}