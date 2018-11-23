<div class="row justify-content-center">
    <div class="col-md-8">
        <form action="{{ action('ReplyController@store', $thread) }}" method="post">
            @csrf
            <div class="form-group">
                <textarea name="body" id="body" rows="5" placeholder="Have something to say?" class="form-control"></textarea>
            </div>
            <button type="submit" class="btn btn-default">Post</button>
        </form>
    </div>
</div>