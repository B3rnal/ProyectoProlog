// Model params
var canvas;
var lastNodeSelected, lastEdgeSelected;

// View helpers
var nodeBtn;

function disable(d) {
    d.attr("disabled", true);
};

function enable(d) {
    d.attr("disabled", false);
};

function Vertex(x, y) {
    this.x = x;
    this.y = y;
    this.nodeId = 'n'+nodesIds++;
    this.links = [];
    this.hasCurl = false;

    nodes.push(this);
};

function Link(nodeLeft, nodeRight) {
    this.left = nodeLeft,
    this.right = nodeRight,
    this.edgeId = 'e'+edgesIds++;
    moves.push([this.edgeId, nodeLeft.nodeId, nodeRight.nodeId]);
    //Is Curl
    if (Object.is(this.right, this.left)){
        this.left.hasCurl = true;
        this.left.links.push({'nodeId':this.left.nodeId, 'edgeId': this.edgeId });
    }else{
        this.left.links.push({'nodeId':this.right.nodeId, 'edgeId': this.edgeId });
        this.right.links.push({'nodeId':this.left.nodeId, 'edgeId': this.edgeId });
    }

    edges.push(this);

}

//JSON for request or analisys
var nodes = [];
var edges = [];
var moves = [];

// On ready
$(function() {
    //set params up
    canvas = $("#canvas");

    //Last selected
    var lastNodeSelected = null;
    var lastEdgeSelected = null;

    //Consecutivos
    nodesIds = 0;
    edgesIds = 0;
    
    // Model and support functions
    function Point(e) {
        this.x = e.pageX - canvas.offset().left - 9;
        this.y = e.pageY - canvas.offset().top - 9;
    };

    function POINT(e) {
        return new Point(e);
    };

    function IGNORE(e) {
        alert(e);
    };

    function NODE(p) {
        return new Vertex(p.x, p.y);
    };

    function EDGE(nodeLeft, nodeRight) {
        return new Link(nodeLeft, nodeRight);
    };

    function NOT_NULL(n) {
        return n != null;
    };
    
    var click = Rx.Observable.fromEvent(canvas, 'click');
        // Double click on canvas
    var canvasDblClicks = click
        .buffer(function() {
            return click.throttle(250);
        })
        .map(function(list) {
            return [list.length, list];
        })
        .filter(function(x) {
            return x[0] >= 2;
        })
        .map(function(x) {
            return x[1][0];
        })
        .map(POINT)
        .map(NODE)
    ;

    canvasDblClicks.subscribe(drawNode,  IGNORE);


    //UI elements
    var sendBtn = $("#send"), // send graph as JSON
    clearBtn = $("#clear"), // clear full graph
    evalJS = $("#jseval"); 


    var clearclicks = Rx.Observable.fromEvent(clearBtn, 'click')
                                    .map( function(e){ return e.target; } );
    clearclicks.subscribe(clearGraph, IGNORE);


    var sendclicks = Rx.Observable.fromEvent(sendBtn, 'click')
                                    .map( function(e){ return e.target; } );
    sendclicks.subscribe(sendGraph, IGNORE);

    /*
    var evalclicks = Rx.Observable.fromEvent(evalJS, 'click')
                                    .map( function(e){ return e.target; } );
    clearclicks.subscribe(evalGraph, IGNORE);*/

    function clearGraph(target){
        nodes = [];
        edges = [];
        canvas.html('');
        nodesIds = 0;
        edgesIds = 0;
        lastNodeSelected = null;
    }

    function sendGraph(){
        
        var json = {
            'grafo':
            {
                'name': 'g1',
                'moves': moves
            }
        };
        json.grafo.nodes = nodes.map(function(node){
            return node.nodeId;
        });
        json.grafo.edges = edges.map(function(edge){
            return edge.edgeId;
        });

        $.ajax({
            url: '/json',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify(json),
            success: function(data, status, xhr) {
                console.log(data);
            },
            error: function (data, textStatus, jqXHR) {
                console.log(textStatus);
            }
        });
    }

    function drawNode(n, c) {
        var nodeId = nodesIds - 1,
            newNode = $('<span></span>')
                        .attr('id', 'n'+nodeId)
                        .addClass('node-holder')
                        .append($('<span></span>').addClass('node glyphicon glyphicon-record'))
                        .append($('<i></i>').addClass('node-delete glyphicon glyphicon-remove'))
                        .append($('<i></i>').addClass('node-curl glyphicon glyphicon-repeat'))
                        .css('top', n.y).css('left', n.x);

            $('#canvas').append(newNode);

        var nodeClicks = Rx.Observable.fromEvent(newNode.find('.node'), 'click')
                .map(function (e) {
                    return $(e.target).parent();
                });
        nodeClicks.subscribe(toggleBtn);

        var deleteClicks = Rx.Observable.fromEvent(newNode.find('.node-delete'), 'click')
                .map(function() {
                    deleteNode(n);
                    return n;
                });
        deleteClicks.subscribe();

        var curlClicks = Rx.Observable.fromEvent(newNode.find('.node-curl'), 'click')
                .map(function() {
                    drawEdgeCurl(n);
                    return n;
                });
        curlClicks.subscribe();
    };

    function toggleBtn(val){

        currentId = val.attr('id');
        $('.edge').removeClass('selected');
        if(lastNodeSelected == null){
            $('.node-holder').removeClass('selected'); 
            $(val).addClass('selected');
            lastNodeSelected = getNode(currentId);
        }else{
            if(!isLastSelectedNode( currentId )) {
                $('.node-holder').removeClass('selected');
                drawEdge(lastNodeSelected, getNode(currentId));
            }else{
                lastNodeSelected = null;
                $(val).removeClass('selected');
            }
        }

    }

    function isLastSelectedNode(id){
        var result = false;
        nodes.forEach(function(node, index){
            if(node.nodeId == id && id == lastNodeSelected.nodeId){
                result = true;
            }
        });
        return result;
    };

    function getNode(id){
        var nodeResult = null;
        nodes.forEach(function(node){
            if(node.nodeId == id){
                nodeResult = node;
            }
        });
        return nodeResult;
    };

    function getEdge(id){
        var edgeResult = null;
        edges.forEach(function(edge){
            if(edge.edgeId == id){
                edgeResult = edge;
            }
        });
        return edgeResult;
    };


    function deleteNode(n) {
        $('.node-holder.selected').remove();

        if(isLastSelectedNode(n.nodeId)){
            lastNodeSelected = null;
        }

        var edgeToDelete = null;
        n.links.forEach(function(val){
            edgeToDelete = getEdge(val.edgeId);
            edges.splice(edges.indexOf(edgeToDelete), 1); 
            $('#'+val.edgeId).remove();
        });
        nodes.splice(nodes.indexOf(n), 1);

        if(nodes.length > 0){
            nodes.forEach(function(val){
                var filtered = val.links.filter(function(link){
                    return n.nodeId !== link.nodeId;
                });
                val.links = filtered;
            });
        }

    };

    function drawEdge(nodeA, nodeB) {

        lastNodeSelected = null;

        var newLink = EDGE(nodeA, nodeB);

        var edgeId = edgesIds - 1,

        angleInDegrees = getAngle(nodeA, nodeB),

        distance = getDistance(nodeA, nodeB),

        coordinates = getCoordinates(nodeA, nodeB, distance),
        
        newEdge = $('<span></span>')
            .append(
                $('<i></i>').addClass('edge-delete glyphicon glyphicon-remove')
                .css('left', distance/2 + 'px')
            )
            .attr('id', 'e'+edgeId)
            .addClass('edge sample')
            .css('width', distance +'px')
            .css('top', coordinates.edgeTop + 'px')
            .css('left', coordinates.edgeLeft + 'px')
            .css('transform', 'rotate('+ ( angleInDegrees ) +'deg)');

        canvas.append(newEdge);

        var deleteClicks = Rx.Observable.fromEvent(newEdge.find('.edge-delete'), 'click')
                .map(function(e) {
                    deleteEdge( newLink, nodeA, nodeB, $(e.target).parent() );
                    return newLink;
                });
        deleteClicks.subscribe();

        var edgeClicks = Rx.Observable.fromEvent(newEdge, 'click')
                .map(function (e) {
                    return $(e.target);
                });

        edgeClicks.subscribe(toggleEdge);

    };

    function toggleEdge(val){
        $('.node-holder').removeClass('selected'); 
        if($(val).hasClass('selected')){
            $('.edge').removeClass('selected');
        }else{
            $('.edge').removeClass('selected');
            $(val).addClass('selected');
        }
    }

    function getCoordinates(nodeA, nodeB, distance){

        var edgeTop = 0, edgeLeft = 0, distanceHalf = distance/2;

        halfAB = ( nodeB.x - nodeA.x )/2;

        edgeLeft = ( ( nodeB.x - halfAB ) - (distanceHalf) ) + 9 ;

        edgeTop = ( ( nodeA.y - nodeB.y )/2 + nodeB.y ) + 9;

        return {'edgeTop':edgeTop, 'edgeLeft': edgeLeft};
    }

    function getAngle(nodeA, nodeB ){
        var deltaY, deltaX;

        deltaX = nodeB.x - nodeA.x,
        deltaY = nodeB.y - nodeA.y;

        return Math.atan2(deltaY, deltaX) * 180 / Math.PI;
    }

    function getDistance( nodeA, nodeB ){
      var xs = 0;
      var ys = 0;
     
      xs = nodeB.x - nodeA.x;
      xs = xs * xs;
     
      ys = nodeB.y - nodeA.y;
      ys = ys * ys;
     
      return Math.sqrt( xs + ys );
    }

    function drawEdgeCurl(node) {
        $('.node-holder.selected').addClass('hasCurl');
        $('.node-holder').removeClass('selected');
        lastNodeSelected = null;

        var newLink = EDGE(node, node);

        var edgeId = edgesIds - 1;
        
        newEdge = $('<span></span>')
            .append(
                    $('<i></i>').addClass('edge-delete glyphicon glyphicon-remove')
                    .css('left', 17 + 'px')
                    .css('top', -17 + 'px')
                )
            .attr('id', 'e'+edgeId)
            .addClass('edge sample curl')
            .css('top', ( node.y - 40 ) + 'px')
            .css('left', ( node.x - 17 ) + 'px');

        canvas.append(newEdge);


        var deleteClicks = Rx.Observable.fromEvent(newEdge.find('.edge-delete'), 'click')
                .map(function(e) {
                    deleteEdge( newLink, node, node, $(e.target).parent(), true);
                    return newLink;
                });
        deleteClicks.subscribe();

        var edgeClicks = Rx.Observable.fromEvent(newEdge, 'click')
                .map(function (e) {
                    return $(e.target);
                });

        edgeClicks.subscribe(toggleEdge);
    };

    function deleteEdge(edge, nodeA, nodeB, htmlEdge, isCurl) {

        if(isCurl){
            $('#'+nodeA.nodeId).removeClass('hasCurl');
        }
        htmlEdge.remove();

        edges.splice(edges.indexOf(edge), 1); 

        var newALinks = nodeA.links.filter(function(link){
            return link.edgeId != edge.edgeId;
        });

        nodeA.links = newALinks;

        var newBLinks = nodeB.links.filter(function(link){
            return link.edgeId != edge.edgeId;
        });

        nodeB.links = newBLinks;        
    };

}); //ready