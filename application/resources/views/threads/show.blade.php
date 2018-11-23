@extends('layouts.app')

@section('content')
<div class="container">
    <h3 class="text-center">Thread</h3>

    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">
                    <a href="#">
                        {{ $thread->creator->name }}
                    </a>
                    posted: {{ $thread->title }}
                </div>

                <div class="card-body">
                    {{ $thread->body }}
                </div>
            </div>
        </div>
    </div>

    <h3 class="text-center">Replies</h3>

    @foreach ($thread->replies as $reply)
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card">
                    <div class="card-header">
                        <a href="#">
                            {{ $reply->owner->name }}
                        </a>
                        
                        said {{ $reply->created_at->diffForHumans() }}
                    </div>
                    <div class="card-body">
                        {{ $reply->body }}
                    </div>
                </div>
            </div>
        </div>
    @endforeach

    @if (auth()->check())
        @include('threads.form')
    @else
        <p class="text-center">Please <a href="{{ route('login') }}">sign in</a> to participate in this discussion.</p>
    @endif
</div>
@endsection
